local ffi = require('ffi')
local utils = require('utils')

---Wrapper around `utils.stl.hl()` that forces apply hlgroup even in tty
---@param str? string sign symbol
---@param hl? string name of the highlight group
---@param restore? boolean restore highlight after the sign, default true
local function make_hl(str, hl, restore)
  return utils.stl.hl(str, hl, restore, true)
end

---@type table<integer, integer>
local lnumw_cache = {}

---@class stc_shared_data_t
---@field win integer
---@field wp ffi.cdata* winpos_T C struct for window attributes
---@field display_tick? integer display tick
---@field buf_tick? integer b:changedtick
---@field buf? integer
---@field lnumw? integer number of digits of the largest line number
---@field nu? boolean &number
---@field rnu? boolean &relativenumber
---@field nuw? integer &numberwidth
---@field scl? string &signcolumn
---@field fdc? string &foldcolumn
---@field show_nu? boolean whether to show line number (either &nu or &rnu is true)
---@field show_scl? boolean whether to show sign column
---@field show_fdc? boolean whether to show fold column
---@field cur? integer[] cursor position
---@field cul? boolean &cursorline
---@field culopt? string &cursorlineopt
---@field culhl? boolean whether to use cursorline highlight at current line
---@field lnumabovehl? boolean whether to use LineNrAbove at current line in number column
---@field lnumbelowhl? boolean whether to use LineNrBelow at current line in number column
---@field foldopen? string fold open sign
---@field foldclose? string fold close sign
---@field foldsep? string fold separator sign
---@field extsigns? extmark_sign_t[] extmark signs, see `:h extmarks`
---@field lnum? integer v:lnum
---@field relnum? integer v:relnum
---@field virtnum? integer v:virtnum

---@class extmark_sign_t
---@field [1] integer extmark_id
---@field [2] integer row, 0-indexed
---@field [3] integer col, 0-indexed
---@field [4] extmark_sign_details_t details

---@class extmark_sign_details_t: vim.api.keyset.set_extmark
---@field sign_name string? only set when sign is defined using legacy `sign_define()`
---@field ns_id integer

---Shared data in each window
---@type table<string, stc_shared_data_t>
local shared = {}

---@type table<string, fun(data: stc_shared_data_t, ...): string>
local builders = {}

ffi.cdef([[
  typedef struct {} Error;
  typedef struct {} win_T;
  typedef struct {
    int start;  // line number where deepest fold starts
    int level;  // fold level, when zero other fields are N/A
    int llevel; // lowest level that starts in v:lnum
    int lines;  // number of lines from v:lnum to end of closed fold
  } foldinfo_T;
  foldinfo_T fold_info(win_T* wp, int lnum);
  win_T *find_window_by_handle(int Window, Error *err);

  // Display tick, incremented for each call to update_screen()
  uint64_t display_tick;
]])

---Returns the string representation of sign column to be shown
---@param data stc_shared_data_t
---@param filter fun(sign: extmark_sign_t, data: stc_shared_data_t): boolean
---@param virtual boolean whether to draw sign in virtual line
---@return string
function builders.signcol(data, filter, virtual)
  if not data.show_scl then
    return ''
  end
  if data.virtnum ~= 0 and not virtual then
    goto signcol_ret_default
  end
  do
    ---@type extmark_sign_details_t?
    local sign_details
    for _, sign in ipairs(data.extsigns) do
      local lnum = sign[2] + 1 -- 0-indexed to 1-indexed
      local current_sign_details = sign[4]
      if lnum > data.lnum then
        break
      end
      if
        lnum == data.lnum
        and filter(sign, data)
        and current_sign_details.sign_text
        and (
          not sign_details
          or current_sign_details.priority > sign_details.priority
        )
      then
        sign_details = current_sign_details
      end
    end
    if sign_details then
      return make_hl(
        vim.trim(sign_details.sign_text),
        data.culhl and sign_details.cursorline_hl_group
          or sign_details.sign_hl_group --[[@as string]]
      )
    end
  end
  ::signcol_ret_default::
  return make_hl(' ', data.culhl and 'CursorLineSign' or 'SignColumn')
end

---@param data stc_shared_data_t
---@return string
function builders.lnum(data)
  local result = '' ---@type string|integer
  if not data.show_nu then
    return ''
  end
  if data.virtnum ~= 0 then -- Drawing virtual line
    goto lnum_ret_default
  end
  if not data.nu then
    result = data.relnum
    goto lnum_ret_default
  end
  if not data.rnu then
    result = data.lnum
    goto lnum_ret_default
  end
  if data.relnum == 0 then
    return string.format(
      '%%=%-' .. math.max(data.nuw - 1, data.lnumw or 0) .. 'd ',
      data.lnum
    )
  end
  result = data.relnum

  ::lnum_ret_default::
  return string.format(
    '%%=%' .. math.max(data.nuw - 1, data.lnumw or 0) .. 's ',
    result
  )
end

---@param data stc_shared_data_t
---@return string
function builders.foldcol(data)
  if not data.show_fdc then
    return ''
  end
  local lnum = data.lnum --[[@as integer]]
  local foldinfo = ffi.C.fold_info(data.wp, lnum)
  local foldchar = (data.virtnum ~= 0 or foldinfo.start ~= lnum)
      and data.foldsep
    or foldinfo.lines == 0 and data.foldopen
    or data.foldclose
  return make_hl(foldchar, data.culhl and 'CursorLineFold' or 'FoldColumn')
end

---Get a valid name of an extmark sign
---@param sign extmark_sign_t
---@return string
local function extsign_get_name(sign)
  local details = sign[4]
  return details.sign_name or details.sign_hl_group or '' --[[@as string]]
end

---@param sign extmark_sign_t
---@param data stc_shared_data_t
---@return boolean
local function gitsigns_filter(sign, data)
  local name = extsign_get_name(sign)
  if not name:find('^Git') then
    return false
  end
  if data.virtnum ~= 0 then -- virtual lines, not showing git delete signs
    return not name:find('[Dd]elete$')
  end
  return true
end

---@param sign extmark_sign_t
---@return boolean
local function nongitsigns_filter(sign)
  return not extsign_get_name(sign):find('^Git')
end

---Get number of digits of a decimal integer
---@param number integer
---@return integer
local function numdigits(number)
  local result = 0
  while number >= 1 do
    number = number / 10
    result = result + 1
  end
  return result
end

---@return string
function _G._stc()
  local win = vim.g.statusline_winid
  local display_tick = ffi.C.display_tick --[[@as uinteger]]
  if not shared[win] then -- Initialize shared data
    shared[win] = {
      win = win,
      wp = ffi.C.find_window_by_handle(win, ffi.new('Error')),
    }
  end

  local data = shared[win]
  if not data.display_tick or data.display_tick < display_tick then -- Update shared data
    local wo = vim.wo[win]
    local fcs = vim.opt_local.fillchars:get()
    local buf = vim.api.nvim_win_get_buf(win)
    local wininfo = vim.fn.getwininfo(win)[1]
    data.display_tick = display_tick
    data.buf = buf
    data.cur = vim.api.nvim_win_get_cursor(win)
    data.cul = wo.cul
    data.culopt = wo.culopt
    data.nu = wo.nu
    data.rnu = wo.rnu
    data.nuw = wo.nuw
    data.scl = wo.scl
    data.fdc = wo.fdc
    data.show_nu = data.nu or data.rnu
    data.show_scl = data.scl ~= 'no'
    data.show_fdc = data.fdc ~= '0'
    data.foldopen = fcs.foldopen or '-'
    data.foldclose = fcs.foldclose or '+'
    data.foldsep = fcs.foldsep or '|'
    data.extsigns = vim.api.nvim_buf_get_extmarks(
      buf,
      -1,
      { wininfo.topline - 1, 0 },
      { wininfo.botline - 1, -1 },
      {
        type = 'sign',
        details = true,
      }
    )

    -- lnum width is only needed when both &nu and &rnu are enabled
    if data.nu and data.rnu then
      local buf_tick = vim.api.nvim_buf_get_changedtick(buf)
      if not data.buf_tick or data.buf_tick < buf_tick then
        lnumw_cache[buf] = numdigits(vim.api.nvim_buf_line_count(buf))
        data.buf_tick = buf_tick
      end
      -- Cache could be nil after BufDelete
      data.lnumw = lnumw_cache[buf] or data.lnumw
    end
  end

  data.lnum = vim.v.lnum
  data.relnum = vim.v.relnum
  data.virtnum = vim.v.virtnum

  data.culhl = data.cul
    and data.culopt:find('[ou]')
    and data.lnum == data.cur[1]

  return builders.signcol(data, nongitsigns_filter)
    .. (data.show_scl and ' ' or '')
    .. builders.lnum(data)
    .. builders.signcol(data, gitsigns_filter, true)
    .. builders.foldcol(data)
    .. (data.show_fdc and ' ' or '')
end

---@return nil
local function setup()
  if vim.g.loaded_statuscolumn ~= nil then
    return
  end
  vim.g.loaded_statuscolumn = true

  ---Attach statuscolumn to current window
  local function _attach()
    if
      vim.bo.bt == ''
      and vim.wo.stc == ''
      and vim.fn.win_gettype() == ''
      and not vim.b.bigfile
    then
      vim.opt_local.stc = '%!v:lua._stc()'
    end
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_call(win, _attach)
  end

  local augroup = vim.api.nvim_create_augroup('StatusColumn', {})
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufWinEnter' }, {
    group = augroup,
    desc = 'Set statuscolumn for each window.',
    callback = function()
      _attach()
    end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = augroup,
    desc = 'Clear per window shared data cache.',
    callback = function(info)
      shared[tonumber(info.match)] = nil
    end,
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    group = augroup,
    desc = 'Clear per buffer lnum width cache.',
    callback = function(info)
      lnumw_cache[info.buf] = nil
    end,
  })
end

return {
  setup = setup,
}
