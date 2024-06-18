local lsconds = require('luasnip.extras.conditions')
local utils = require('utils')

---@class snip_cond_t
---@operator call: boolean
---@operator unm: snip_cond_t
---@operator add: snip_cond_t
---@operator mul: snip_cond_t
---@operator pow: snip_cond_t
---@operator mod: snip_cond_t

---@class snip_conds_t
---@field make_condition function
local M = setmetatable({ _ = {} }, {
  __index = function(self, k)
    if self._[k] then
      local cond = lsconds.make_condition(self._[k])
      rawset(self, k, cond)
      return cond
    end
    return lsconds[k]
  end,
  __newindex = function(self, k, v)
    self._[k] = v
  end,
})

---Returns whether the cursor is in a math zone
---@return boolean
function M.in_mathzone()
  return utils.ft.markdown.in_mathzone()
end

---Returns whether the cursor is in a code block
---@return boolean
function M.in_codeblock()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return utils.ft.markdown.in_codeblock(cursor[1])
end

---Returns whether the current buffer has treesitter enabled
---@return boolean
function M.ts_active()
  return utils.treesitter.is_active()
end

---Returns whether current cursor is in a comment
---@param type string
---@return snip_cond_t
function M.in_tsnode(type)
  return lsconds.make_condition(function()
    return utils.treesitter.in_tsnode(type)
  end)
end

---Returns whether the cursor is in a normal zone
---@return boolean
function M.in_normalzone()
  if vim.bo.ft == 'markdown' or vim.bo.ft == 'tex' then
    return utils.ft[vim.bo.ft].in_normalzone()
  end
  return not M.ts_active()
    or not M.in_tsnode('comment')() and not M.in_tsnode('string')()
end

---Returns whether the cursor is before a pattern
---@param pattern string lua pattern
---@return snip_cond_t
function M.before_pattern(pattern)
  return lsconds.make_condition(function()
    return vim.api
      .nvim_get_current_line()
      :sub(vim.api.nvim_win_get_cursor(0)[2] + 1)
      :match('^' .. pattern) ~= nil
  end)
end

---Returns whether the cursor is after a pattern
---@param pattern string lua pattern
---@return snip_cond_t
function M.after_pattern(pattern)
  ---@param matched_trigger string the fully matched trigger
  return lsconds.make_condition(function(_, matched_trigger)
    return vim.api
      .nvim_get_current_line()
      :sub(1, vim.api.nvim_win_get_cursor(0)[2])
      :gsub(vim.pesc(matched_trigger) .. '$', '', 1)
      :match(pattern .. '$') ~= nil
  end)
end

---Returns whether the cursor is at the start of a line
---@param matched_trigger string the fully matched trigger
---@return boolean
function M.at_line_start(_, matched_trigger)
  return vim.api
    .nvim_get_current_line()
    :sub(1, vim.api.nvim_win_get_cursor(0)[2])
    :gsub(matched_trigger or '', '') == ''
end

---Returns whether the cursor is at the end of a line
---@return boolean
function M.at_line_end()
  return vim.api.nvim_win_get_cursor(0)[2] == #vim.api.nvim_get_current_line()
end

---Returns whether the previous line matches a pattern
---@param pattern string lua pattern
---@return snip_cond_t
function M.prev_line_matches(pattern)
  return lsconds.make_condition(function()
    local lnum = vim.fn.line('.')
    if lnum <= 1 then
      return false
    end
    return vim.api
      .nvim_buf_get_lines(0, lnum - 2, lnum - 1, true)[1]
      :match(pattern) ~= nil
  end)
end

---Returns whether the next line matches a pattern
---@param pattern string lua pattern
---@return snip_cond_t
function M.next_line_matches(pattern)
  return lsconds.make_condition(function()
    local lnum = vim.fn.line('.')
    if lnum >= vim.api.nvim_buf_line_count(0) then
      return false
    end
    return vim.api
      .nvim_buf_get_lines(0, lnum, lnum + 1, true)[1]
      :match(pattern) ~= nil
  end)
end

return M
