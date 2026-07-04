local M = {}
local ts = require('utils.ts')
local syn = require('utils.syn')

---Returns whether the cursor is in a tex math zone (excluding `\text{}`)
---@return boolean
function M.in_mathzone()
  if ts.is_active() then
    -- Requires latex treesitter parser
    return ts.find_node(
      { 'formula', 'equation', 'math' },
      { ignore_injections = false }
    ) ~= nil and ts.find_node(
      { 'text_mode' },
      { ignore_injections = false }
    ) == nil
  end

  -- Fall back to vim legacy regex syntax
  if vim.b.current_syntax then
    return syn.find_group({ 'texMathZone' }) ~= nil
      and syn.find_group({ 'texMathText' }) == nil
  end

  return false
end

---Returns whether the cursor is in a code block
---@return boolean
function M.in_codeblock()
  if ts.is_active() then
    return ts.find_node({ 'fence' }) ~= nil
  end

  if vim.b.current_syntax then
    return syn.find_group({ 'CodeBlock' }) ~= nil
  end

  return false
end

---Returns whether the cursor is in a normal zone
---@return boolean
function M.in_normalzone()
  if ts.is_active() then
    return ts.find_node(
      { 'comment', 'string', 'fence', 'formula', 'equation', 'math' },
      { ignore_injections = false }
    ) == nil
  end

  if vim.b.current_syntax then
    return syn.find_group({
      'Comment',
      'String',
      'Code',
      'MathZone',
    }) == nil
  end

  return true
end

return M
