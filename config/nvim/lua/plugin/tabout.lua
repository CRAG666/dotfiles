local fmt = string.format

---@class fallbak_tbl_t each key shares a default / fallback pattern table
---that can be used for pattern matching if corresponding key is not present
---or non patterns stored in the key are matched
---@field __content table closing patterns for each filetype
---@field __default table
local fallback_tbl_t = {}

function fallback_tbl_t:__index(k)
  return fallback_tbl_t[k] or self:fallback(k)
end

function fallback_tbl_t:__newindex(k, v)
  self.__content[k] = v
end

---Get the table with the fallback patterns for kdest
---@param k string key
---@return table concatenated table
function fallback_tbl_t:fallback(k)
  local dest = self.__content[k]
  local default = self.__default
  if dest and default then
    if vim.islist(dest) and vim.islist(default) then
      return vim.list_extend(dest, default)
    else
      dest = vim.tbl_deep_extend('keep', dest, default)
      return dest
    end
  elseif dest then
    return dest
  elseif default then
    return default
  end
  return {}
end

---Create a new shared table
---@param args table
---@return fallbak_tbl_t
function fallback_tbl_t:new(args)
  args = args or {}
  local fallback_tbl = {
    __content = args.content or {},
    __default = args.default or {},
  }
  return setmetatable(fallback_tbl, self)
end

-- stylua: ignore start
local closing_patterns = fallback_tbl_t:new({
  default = {
    '\\%)',
    '\\%)',
    '\\%]',
    '\\}',
    '%)',
    '%]',
    '}',
    '"',
    "'",
    '`',
    ',',
    ';',
    '%.',
  },
  content = {
    c = { '%*/' },
    cpp = { '%*/' },
    cuda = { '>>>' },
    lua = { '%]=*%]' },
    python = { '"""', "'''" },
    html = { '<[^>]*>' },
    xml = { '<[^>]*>' },
    markdown = {
      '\\right\\rfloor',
      '\\right\\rceil',
      '\\right\\vert',
      '\\right\\Vert',
      '\\right%)',
      '\\right%]',
      '\\right}',
      '\\right>',
      '\\%]',
      '\\}',
      '-->',
      '<[^>]*>',
      '%*%*%*',
      '%*%*',
      '%*',
      '%$',
      '|',
    },
    tex = {
      '\\right\\rfloor',
      '\\right\\rceil',
      '\\right\\vert',
      '\\right\\Vert',
      '\\right%)',
      '\\right%]',
      '\\right}',
      '\\right>',
      '\\%]',
      '\\}',
      '%$',
    },
  },
})

local opening_pattern_lookup_tbl = {
  ["'"]               = "'",
  ['"']               = '"',
  [',']               = '.',
  [';']               = '.',
  ['`']               = '`',
  ['|']               = '|',
  ['}']               = '{',
  ['%.']              = '.',
  ['%$']              = '%$',
  ['%)']              = '%(',
  ['%]']              = '%[',
  ['%*']              = '%*',
  ['<<<']             = '>>>',
  ['%*%*']            = '%*%*',
  ['%*%*%*']          = '%*%*%*',
  ['"""']             = '"""',
  ["'''"]             = "'''",
  ['%*/']             = '/%*',
  ['\\}']             = '\\{',
  ['-->']             = '<!--',
  ['\\%)']            = '\\%(',
  ['\\%]']            = '\\%[',
  ['%]=*%]']          = '--%[=*%[',
  ['<[^>]*>']         = '<[^>]*>',
  ['\\right}']        = '\\left{',
  ['\\right>']        = '\\left<',
  ['\\right%)']       = '\\left%(',
  ['\\right%]']       = '\\left%[',
  ['\\right\\vert']   = '\\left\\vert',
  ['\\right\\Vert']   = '\\left\\lVert',
  ['\\right\\rceil']  = '\\left\\lceil',
  ['\\right\\rfloor'] = '\\left\\lfloor',
}
-- stylua: ignore end

---Get the length of a string, if the given string is nil, return 0
---@param str string?
---@return number length of the string
local function slen(str)
  return str and str:len() or 0
end

---Check if the cursor is in cmdline
---@return boolean
local function in_cmdline()
  return vim.fn.mode():match('^c') ~= nil
end

---Get the cursor position, whether in cmdline or normal buffer
---@return number[] cursor: 1,0-indexed cursor position
local function get_cursor()
  return in_cmdline() and { 1, vim.fn.getcmdpos() - 1 }
    or vim.api.nvim_win_get_cursor(0)
end

---Get current line, whether in cmdline or normal buffer
---@return string current_line: current line
local function get_line()
  return in_cmdline() and vim.fn.getcmdline()
    or vim.api.nvim_get_current_line()
end

---@param text string text to find patterns in
---@return number?
local function get_tabout_offset(text)
  local min_offset ---@type number?
  for _, pattern in ipairs(closing_patterns[vim.bo.ft]) do
    local _, offset = text:find('%s*' .. pattern)
    if offset then
      min_offset = min_offset and math.min(min_offset, offset) or offset
    end
  end
  return min_offset
end

---Getting the jump position for Tab
---@return number[]? cursor position after jump; nil if no jump
local function get_tabout_pos()
  local cursor = get_cursor()
  local current_line = get_line()
  local trailing = current_line:sub(cursor[2] + 1, -1)
  local leading = current_line:sub(1, cursor[2])

  -- Do not jump if the cursor is at the beginning of the current line
  if leading:match('^%s*$') then
    return
  end

  local offset = get_tabout_offset(trailing)
  if offset then
    return {
      cursor[1],
      cursor[2] + offset,
    }
  end

  -- Jump to the end of the line if no closing pattern is found and not already
  -- at end of line
  if trailing ~= '' then
    return {
      cursor[1],
      slen(current_line),
    }
  end

  -- If already at end of line, find opening closing patterns in lines below
  -- cursor, this is useful to jump out curly braces that takes a seprate lien
  -- in C-style languages, e.g.
  --
  -- int my_func(void) {
  --   ...|
  -- } <- jump to here
  local next_nonblank_linenr = vim.fn.nextnonblank(cursor[1] + 1) -- 1-based line number
  if next_nonblank_linenr > 0 then
    local next_nonblank_offset = get_tabout_offset(
      vim.api.nvim_buf_get_lines(
        0,
        next_nonblank_linenr - 1,
        next_nonblank_linenr,
        false
      )[1]
    )
    if next_nonblank_offset then
      return {
        next_nonblank_linenr,
        next_nonblank_offset,
      }
    end
  end
end

---Get the offset of the position where Shift-Tab should jump to
---1. If there are only whitespace characters or no characters in between
---   the opening and closing pattern, jump to the middle of the whitespaces
---2. If there is contents (non-whitespace characters) in between the
---   opening and closing pattern, jump to the end of the contents
---@param leading any leading texts on current line
---@param closing_pattern any closing pattern
---@return number offset column offset after jump
---@return number closing_len length of matched closing pattern
local function get_tabin_offset_with_closing_pattern(leading, closing_pattern)
  local opening_pattern = opening_pattern_lookup_tbl[closing_pattern]

  -- Case 1
  local _, _, content, closing, trailing =
    leading:find(fmt('%s(%%s*)(%s)(.*)$', opening_pattern, closing_pattern))
  if content == nil or closing == nil then
    _, _, content, closing, trailing =
      leading:find(fmt('^(%%s*)(%s)(.*)$', closing_pattern))
  end

  if content and closing then
    return slen(trailing) + slen(closing) + math.floor(slen(content) / 2),
      slen(closing) + math.floor(slen(content) / 2)
  end

  -- Case 2
  _, _, _, closing, trailing = leading:find(
    fmt('%s%%s*.*%%S(%%s*%s)(.*)$', opening_pattern, closing_pattern)
  )

  if content == nil or closing == nil then
    _, _, closing, trailing =
      leading:find(fmt('%%S(%%s*%s)(.*)$', closing_pattern))
  end

  return slen(trailing) + slen(closing), slen(closing)
end

---@param leading string leading texts before cursor
---@param prev_offset number? previous column offset
---@return number: offset column offset after jump
local function get_tabin_offset(leading, prev_offset)
  prev_offset = prev_offset or 0
  if leading == '' then
    return prev_offset
  end

  for _, pattern in ipairs(closing_patterns[vim.bo.ft]) do
    local offset, closing_len =
      get_tabin_offset_with_closing_pattern(leading, pattern)
    if offset > 0 then
      return get_tabin_offset(
        leading:sub(slen(leading) - offset + closing_len + 1),
        offset
      )
    end
  end

  return prev_offset
end

---Getting the jump position for Shift-Tab
---@return number[]? cursor position after jump; nil if no jump
local function get_tabin_pos()
  local cursor = get_cursor()
  local current_line = get_line()
  local leading = current_line:sub(1, cursor[2])

  local offset = get_tabin_offset(leading)
  if offset > 0 then
    return {
      cursor[1],
      cursor[2] - offset,
    }
  end

  -- Jump to the beginning of the line if no closing pattern is found and not
  -- already at beginning of line
  if leading ~= '' then
    return {
      cursor[1],
      0,
    }
  end

  -- If already at beginning of line, jump to the end of previous non-blank
  -- line
  local prev_nonblank_linenr = vim.fn.prevnonblank(cursor[1] - 1)
  if prev_nonblank_linenr > 0 then
    return {
      prev_nonblank_linenr,
      slen(
        vim.api.nvim_buf_get_lines(
          0,
          prev_nonblank_linenr - 1,
          prev_nonblank_linenr,
          false
        )[1]
      ),
    }
  end
end

---@param direction 1|-1 1 for tabout, -1 for tabin
---@return number[]? cursor position after jump; nil if no jump
local function get_jump_pos(direction)
  if direction == 1 then
    return get_tabout_pos()
  else
    return get_tabin_pos()
  end
end

local KC_RIGHT = vim.keycode('<Right>')
local KC_LEFT = vim.keycode('<Left>')

---Set the cursor position, whether in cmdline or normal buffer
---@param pos number[] cursor position
---@return nil
local function set_cursor(pos)
  if in_cmdline() then
    local cursor = get_cursor()
    local diff = pos[2] - cursor[2]
    local termcode =
      string.rep(diff > 0 and KC_RIGHT or KC_LEFT, math.abs(diff))
    vim.api.nvim_feedkeys(termcode, 'nt', true)
  else
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

local KC_START_NEW_UNDO = vim.keycode('<C-g>u')

---Get the position to jump for Tab or Shift-Tab, perform the jump if
---there is a position to jump to
---@param direction 1|-1 1 for tabout, -1 for tabin
---@return boolean? success
local function jump(direction)
  local pos = get_jump_pos(direction)
  if pos then
    set_cursor(pos)
    -- Start new undo block after moving cursor, else changes made
    -- after the cursor jump cannot be undone
    vim.api.nvim_feedkeys(KC_START_NEW_UNDO, 'nt', false)
    return true
  end
end

---Init tabout plugin
---@return nil
local function setup()
  if vim.g.loaded_tabout ~= nil then
    return
  end
  vim.g.loaded_tabout = true

  local key = require('utils.key')

  key.amend('i', '<Tab>', function(fallback)
    if not jump(1) then
      fallback()
    end
  end, { desc = 'Tab out' })

  key.amend('i', '<S-Tab>', function(fallback)
    if not jump(-1) then
      fallback()
    end
  end, { desc = 'Tab in' })
end

return {
  setup = setup,
  jump = jump,
  get_jump_pos = get_jump_pos,
}
