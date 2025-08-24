local hl = require('utils.hl')

---Resolve the colorcolumn value
---@param cc string|nil
---@return integer|nil cc_number smallest integer >= 0 or nil
local function cc_resolve(cc)
  if not cc or cc == '' then
    return nil
  end
  local cc_tbl = vim.split(cc, ',')
  local cc_min = nil
  for _, cc_str in ipairs(cc_tbl) do
    local cc_number = tonumber(cc_str)
    if vim.startswith(cc_str, '+') or vim.startswith(cc_str, '-') then
      cc_number = vim.bo.tw > 0 and vim.bo.tw + cc_number or nil
    end
    if cc_number and cc_number > 0 and (not cc_min or cc_number < cc_min) then
      cc_min = cc_number
    end
  end
  return cc_min
end

---Default options
---@class cc_opts_t
local opts = {
  scope = function()
    return vim.fn.strdisplaywidth(vim.fn.getline('.'))
  end,
  ---@type string[]|boolean|fun(mode: string): boolean
  modes = function(mode)
    return mode:find('^[iRss\x13]') ~= nil
  end,
  warning_modes = function() ---@type string[]|boolean|fun(mode: string): boolean
    -- Show warning colors only in insert/replace/selection mode
    return vim.fn.mode():find('^[iRss\x13]')
  end,
  blending = {
    threshold = 0.5,
    colorcode = '#000000',
    hlgroup = { 'Normal', 'bg' },
  },
  warning = {
    alpha = 0.4,
    offset = 0,
    colorcode = '#FF0000',
    hlgroup = { 'Error', 'fg' },
  },
}

local C_NORMAL, C_CC, C_ERROR

---Get background color in hex
---@param hlgroup_name string
---@param field 'fg'|'bg'
---@param fallback string|nil fallback color in hex, default to '#000000' if &bg is 'dark' and '#FFFFFF' if &bg is 'light'
---@return string hex color
local function get_hl_hex(hlgroup_name, field, fallback)
  fallback = fallback or vim.opt.bg == 'dark' and '#000000' or '#FFFFFF'
  if not vim.fn.hlexists(hlgroup_name) then
    return fallback
  end
  -- Do not use link = false here, because nvim will return the highlight
  -- attributes of the remapped hlgroup if link = false when winhl is set
  -- e.g. when winhl=ColorColumn:FooBar, nvim will return the attributes of
  -- FooBar instead of ColorColumn with link = false, but return the
  -- attributes of ColorColumn with link = true
  -- EDIT: solved by manually traversing the hlgroup, see implementation
  -- of `utils.hl.get()`
  local attr_val =
    hl.get(0, { name = hlgroup_name, winhl_link = false })[field]
  return attr_val and hl.dec2hex(attr_val, 6) or fallback
end

---Update base colors: bg color of Normal & ColorColumn, and fg of Error
---@return nil
local function update_hl_hex()
  C_NORMAL = get_hl_hex(
    opts.blending.hlgroup[1],
    opts.blending.hlgroup[2],
    opts.blending.colorcode
  )
  C_ERROR = get_hl_hex(
    opts.warning.hlgroup[1],
    opts.warning.hlgroup[2],
    opts.warning.colorcode
  )
  C_CC = get_hl_hex('ColorColumn', 'bg')
end

---Hide colorcolumn
---@param winid integer? window handler
local function cc_conceal(winid)
  vim.api.nvim_win_call(winid or 0, function()
    if vim.opt_local.winhl:get().ColorColumn ~= '' then ---@diagnostic disable-line: undefined-field
      vim.opt_local.winhl:append({ ColorColumn = '' }) ---@diagnostic disable-line: undefined-field
    end
  end)
end

---Show colorcolumn
---@param winid integer? window handler
local function cc_show(winid)
  vim.api.nvim_win_call(winid or 0, function()
    if vim.opt_local.winhl:get().ColorColumn ~= '_ColorColumn' then ---@diagnostic disable-line: undefined-field
      vim.opt_local.winhl:append({ ColorColumn = '_ColorColumn' }) ---@diagnostic disable-line: undefined-field
    end
  end)
end

---@param opt_name string name of the mode option
---@return fun(): boolean function to check the mode option
local function check_mode_fn(opt_name)
  return function()
    local opt = opts[opt_name] ---@type string[]|boolean|fun(mode: string): boolean
    if type(opt) == 'boolean' then
      return opt ---@type boolean
    end
    if type(opt) == 'function' then
      return opt(vim.fn.mode())
    end
    return type(opt) == 'table'
        and vim.tbl_contains(opt --[=[@as string[]]=], vim.fn.mode())
      or false
  end
end

local check_mode = check_mode_fn('modes')
local check_warning_mode = check_mode_fn('warning_modes')

local cc_bg = nil
local cc_link = nil

---Update colorcolumn highlight or conceal it
---@param winid integer? handler, default 0
---@return nil
local function cc_update(winid)
  winid = winid or 0
  local cc = cc_resolve(vim.wo[winid].cc)
  if not check_mode() or not cc then
    cc_conceal(winid)
    return
  end

  -- Fix 'E976: using Blob as a String' after select a snippet
  -- entry from LSP server using omnifunc `<C-x><C-o>`
  ---@diagnostic disable-next-line: param-type-mismatch
  local length = opts.scope()
  local thresh = opts.blending.threshold
  if 0 < thresh and thresh <= 1 then
    thresh = math.floor(thresh * cc)
  end
  if length < thresh then
    cc_conceal(winid)
    return
  end

  -- Show blended color when len < cc
  local show_warning = check_warning_mode()
    and length >= cc + opts.warning.offset
  if vim.go.termguicolors then
    if not C_CC or not C_NORMAL or not C_ERROR then
      update_hl_hex()
    end
    local new_cc_color = show_warning
        and hl.cblend(C_ERROR, C_NORMAL, opts.warning.alpha).dec
      or hl.cblend(
        C_CC,
        C_NORMAL,
        math.min(1, (length - thresh) / (cc - thresh))
      ).dec
    if new_cc_color ~= cc_bg then
      cc_bg = new_cc_color
      vim.api.nvim_set_hl(0, '_ColorColumn', { bg = cc_bg })
    end
  else
    local link = show_warning and opts.warning.hlgroup[1] or 'ColorColumn'
    if cc_link ~= link then
      cc_link = link
      vim.api.nvim_set_hl(0, '_ColorColumn', { link = cc_link })
    end
  end
  cc_show(winid)
end

---Setup colorcolumn
---@param o cc_opts_t?
local function setup(o)
  if vim.g.loaded_colorcolumn ~= nil then
    return
  end
  vim.g.loaded_colorcolumn = true

  if o then
    opts = vim.tbl_deep_extend('force', opts, o)
  end

  ---Conceal colorcolumn in each window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    cc_conceal(win)
  end

  ---Create autocmds for concealing / showing colorcolumn
  local id = vim.api.nvim_create_augroup('AutoColorColumn', {})
  vim.api.nvim_create_autocmd('WinLeave', {
    desc = 'Conceal colorcolumn in other windows.',
    group = id,
    callback = function()
      cc_conceal()
    end,
  })

  vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Update base colors.',
    group = id,
    callback = update_hl_hex,
  })

  vim.api.nvim_create_autocmd({
    'BufEnter',
    'ColorScheme',
    'CursorMoved',
    'CursorMovedI',
    'ModeChanged',
    'TextChanged',
    'TextChangedI',
    'WinEnter',
    'WinScrolled',
  }, {
    desc = 'Update colorcolumn color.',
    group = id,
    callback = function()
      cc_update()
    end,
  })

  vim.api.nvim_create_autocmd('OptionSet', {
    desc = 'Update colorcolumn color.',
    pattern = { 'colorcolumn', 'textwidth' },
    group = id,
    callback = function()
      cc_update()
    end,
  })
end

setup()
