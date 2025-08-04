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
local M = setmetatable({}, {
  __newindex = function(self, cond_name, cond_fn)
    rawset(
      self,
      cond_name,
      lsconds.make_condition(function(...)
        -- Two cases:
        -- - The original condition function itself returns boolean that
        --   indicates whether the condition is met, in which case we can use
        --   the result as-is. Examples: `in_mathzone()`, `in_codeblock()`
        --
        -- - The condition function is a factory function that returns a
        --   callable with boolean return value that serves as a condition
        --   function.
        --   In this case we wrap the callable with `lsconds.make_condition()`
        --   to turn it into a luasnip condition object. Examples:
        --   `in_tsnode()`, `in_syngroup()`, `before_pattern()`
        local result = cond_fn(...) ---@type boolean|fun(...): boolean
        if not vim.is_callable(result) then
          return result
        end
        return lsconds.make_condition(result)
      end)
    )
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

---Returns whether current cursor is in the given types of treesitter node
---@param type string|string[]
---@param opts ts_find_node_opts_t?
---@return fun(): boolean
function M.in_tsnode(type, opts)
  return function()
    return utils.ts.find_node(type, opts) ~= nil
  end
end

---Returns whether current cursor is in the given names of syntax group
---@param name string|string[]|fun(types: string|string[]): boolean type of node, or function to check node type
---@param opts? syn_find_group_opts_t
---@return fun(): boolean
function M.in_syngroup(name, opts)
  return function()
    return utils.syn.find_group(name, opts) ~= nil
  end
end

---Returns whether current cursor is in a buffer with given filetype
---@param ft string|string[]
---@return fun(): boolean
function M.in_ft(ft)
  if type(ft) ~= 'table' then
    ft = { ft }
  end
  return function()
    return vim.iter(ft):any(function(t)
      return t == vim.bo.ft
    end)
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
  return function(_, matched_trigger)
    return vim.api
      .nvim_get_current_line()
      :sub(1, vim.fn.col('.') - 1)
      :gsub(vim.pesc(matched_trigger) .. '$', '', 1)
      :match(pattern .. '$') ~= nil
  end
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
