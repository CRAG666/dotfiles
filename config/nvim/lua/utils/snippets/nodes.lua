local M = {}

local ls = require('luasnip')
local f = ls.function_node
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node


local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta

local uf = require('utils.snippets.funcs')

---Returns a function node that returns a string for indentation at the given
---depth
---@param depth? number|fun(...): number
---@param argnode_references (number|table)?
---@param node_opts table?
---@return table node
function M.idnt(depth, argnode_references, node_opts)
  depth = depth or 1
  return f(function(...)
    return uf.get_indent_str(depth, ...)
  end, argnode_references, node_opts)
end

---Get de-indented string given depth to de-indent and index of indent capture
---group
---
---Intend to be used in regex triggered snippets where the capture group at
---`capture_idx` contains the indentation string
---@param depth? number|fun(...): number
---@param capture_idx? integer
---@param argnode_references (number|table)?
---@param node_opts table?
---@return table node
function M.ddnt(depth, capture_idx, argnode_references, node_opts)
  depth = depth or 1
  capture_idx = capture_idx or 1
  return f(function(_, parent, ...)
    return uf.get_indent_str(
      math.max(
        0,
        uf.get_indent_depth(parent.snippet.captures[capture_idx]) - depth
      ),
      ...
    )
  end, argnode_references, node_opts)
end

---Returns function node that returns a quotation mark based on the number of
---double quotes and single quotes in the first 128 lines current buffer
---@param default? '"'|"'"
---@return table node
function M.qt(default)
  return f(function()
    return require('utils.snippets.funcs').get_quotation_type(nil, default)
  end)
end

---Returns a dynamic node for suffix snippet
---@param jump_index number?
---@param opening string
---@param closing string
---@return table node
function M.sdn(jump_index, opening, closing)
  return d(jump_index or 1, function(_, snip)
    local symbol = snip.captures[1]
    if symbol == nil or not symbol:match('%S') then
      return sn(nil, { t(opening), i(1), t(closing) })
    end
    return sn(nil, { t(opening), t(symbol), t(closing) })
  end)
end

---Returns a dynamic node to be used as a 'body' in a snippet,
---e.g. body of a function/method, or contents in between latex
---environment tags
---
---When there's previous visual selection, the selection will be
---used as the default content of the body
---@param jump_index number? jump index for the dynamic node
---@param indent_depth number|fun(...): number indentation depth for the body, default 1
---@param default_text false|string? default text for the body, set to false to disable trailing insert nodes
---@return table
function M.body(jump_index, indent_depth, default_text)
  return d(jump_index, function(argnode_texts, parent, ...)
    -- The dynamicNode receives the parent of the dynamicNode, which is not
    -- necessarily the snippet, and only the snippet has `env`
    local selected = type(parent.snippet.env.LS_SELECT_DEDENT) == 'table'
        and parent.snippet.env.LS_SELECT_DEDENT
      or {}
    for idx = 2, #selected do
      if selected[idx]:match('%S') then
        selected[idx] = require('utils.snippets.funcs').get_indent_str(
          indent_depth,
          argnode_texts,
          parent,
          ...
        ) .. selected[idx]
      end
    end
    local selected_text = not vim.tbl_isempty(selected) and selected or nil
    local insert_text = selected_text or default_text
    return sn(nil, {
      M.idnt(indent_depth),
      insert_text ~= false and i(1, insert_text) or nil,
    })
  end)
end

---A format node with repeat_duplicates set to true
M.fmtd = ls.extend_decorator.apply(fmt, {
  repeat_duplicates = true,
})

---A format node with <> as placeholders and repeat_duplicates set to true
M.fmtad = ls.extend_decorator.apply(fmta, {
  repeat_duplicates = true,
})

return M
