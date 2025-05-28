local lsconds = require('luasnip.extras.conditions')
local utils = require('utils')

---@class snip_cond_t
---@operator call: boolean
---@operator unm: snip_cond_t
---@operator add: snip_cond_t
---@operator mul: snip_cond_t
---@operator pow: snip_cond_t
---@operator mod: snip_cond_t

---@alias snip_conds_t table<string, fun(...): (fun(...): boolean)>

---Snippet condition functions
---Fields are automatically wrapped with `lsconds.make_condition()` so that
---they can be used as luasnip condition objects and supports operators like
---`*`, `^`, etc.
---
---When defining a function with arguments, remember to return a function
---that returns a boolean instead of the boolean itself so that it can work
---with the operators unless taking `line_to_cursor`, `matched_trigger`, and
---`captures` (passed in by luasnip) as arguments, see
---`LuaSnip/lua/luasnip/extras/conditions/init.lua`
---@type snip_conds_t
local M = setmetatable({ _ = {} }, {
  __newindex = function(self, k, v)
    rawset(self, k, lsconds.make_condition(v))
  end,
})

---Returns whether the cursor is in a math zone
---@return boolean
function M.in_mathzone()
  if utils.ts.is_active() then
    return utils.ts.find_node(
      { 'formula', 'equation', 'math' }, -- requires latex ts parser
      { ignore_injections = false }
    ) ~= nil
  end

  if vim.b.current_syntax then
    return utils.syn.find_group({ 'MathZone' }) ~= nil
  end

  return false
end

---Returns whether the cursor is in a code block
---@return boolean
function M.in_codeblock()
  if utils.ts.is_active() then
    return utils.ts.find_node({ 'fence' }) ~= nil
  end

  if vim.b.current_syntax then
    return utils.syn.find_group({ 'CodeBlock' }) ~= nil
  end

  return false
end

---Returns whether current cursor is in a comment
---@param type string|string[]
---@param opts vim.treesitter.get_node.Opts?
---@return fun(): boolean
function M.in_tsnode(type, opts)
  return function()
    return utils.ts.find_node(type, opts) ~= nil
  end
end

---Returns whether the cursor is in a normal zone
---@return boolean
function M.in_normalzone()
  if utils.ts.is_active() then
    return utils.ts.find_node(
      { 'comment', 'string', 'fence', 'formula', 'equation', 'math' },
      { ignore_injections = false }
    ) == nil
  end

  if vim.b.current_syntax then
    return utils.syn.find_group({
      'Comment',
      'String',
      'Code',
      'MathZone',
    }) == nil
  end

  return true
end

---Returns whether the cursor is before a pattern
---@param pattern string lua pattern
---@return fun(): boolean
function M.before_pattern(pattern)
  return function()
    return vim.api
      .nvim_get_current_line()
      :sub(vim.fn.col('.'))
      :match('^' .. pattern) ~= nil
  end
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
---@return fun(): boolean
function M.prev_line_matches(pattern)
  return function()
    local lnum = vim.fn.line('.')
    if lnum <= 1 then
      return false
    end
    return vim.fn.getbufoneline(0, lnum - 1):match(pattern) ~= nil
  end
end

---Returns whether the next line matches a pattern
---@param pattern string lua pattern
---@return fun(): boolean
function M.next_line_matches(pattern)
  return function()
    local lnum = vim.fn.line('.')
    if lnum >= vim.api.nvim_buf_line_count(0) then
      return false
    end
    return vim.fn.getbufoneline(0, lnum):match(pattern) ~= nil
  end
end

return M
