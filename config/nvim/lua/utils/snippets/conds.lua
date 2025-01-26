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
  __newindex = function(self, k, v)
    rawset(self, k, lsconds.make_condition(v))
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
  return utils.ft.markdown.in_codeblock(vim.fn.line('.'))
end

---Returns whether current cursor is in a comment
---@param type string|string[]
---@param opts vim.treesitter.get_node.Opts?
---@return boolean
function M.in_tsnode(type, opts)
  return utils.ts.in_node(type, opts)
end

---Returns whether the cursor is in a normal zone
---@return boolean
function M.in_normalzone()
  if utils.ts.is_active() then
    return not utils.ts.in_node(
      { 'comment', 'string', 'block' },
      { ignore_injections = false }
    )
  end

  -- If treesitter is not active, we can only check for markdown and tex
  -- using the regex method to ensure we are not in a code block or math zone
  if vim.bo.ft == 'markdown' or vim.bo.ft == 'tex' then
    return utils.ft[vim.bo.ft].in_normalzone()
  end

  return true
end

---Returns whether the cursor is before a pattern
---@param pattern string lua pattern
---@return boolean
function M.before_pattern(pattern)
  return vim.api
    .nvim_get_current_line()
    :sub(vim.fn.col('.'))
    :match('^' .. pattern) ~= nil
end

---Returns whether the cursor is after a pattern
---@param pattern string lua pattern
---@return snip_cond_t
function M.after_pattern(pattern)
  ---@param matched_trigger string the fully matched trigger
  return lsconds.make_condition(function(_, matched_trigger)
    return vim.api
      .nvim_get_current_line()
      :sub(1, vim.fn.col('.') - 1)
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
    :sub(1, vim.fn.col('.') - 1)
    :gsub(matched_trigger or '%S*', '') == ''
end

---Returns whether the cursor is at the end of a line
---@return boolean
function M.at_line_end()
  return vim.fn.col('.') - 1 == #vim.api.nvim_get_current_line()
end

---Returns whether the previous line matches a pattern
---@param pattern string lua pattern
---@return boolean
function M.prev_line_matches(pattern)
  local lnum = vim.fn.line('.')
  if lnum <= 1 then
    return false
  end
  return vim.fn.getbufoneline(0, lnum - 1):match(pattern) ~= nil
end

---Returns whether the next line matches a pattern
---@param pattern string lua pattern
---@return boolean
function M.next_line_matches(pattern)
  local lnum = vim.fn.line('.')
  if lnum >= vim.api.nvim_buf_line_count(0) then
    return false
  end
  return vim.fn.getbufoneline(0, lnum):match(pattern) ~= nil
end

return M
