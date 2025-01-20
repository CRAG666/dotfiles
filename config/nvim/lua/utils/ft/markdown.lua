local M = {}
local utils = require('utils')

---Check if the current line is a markdown code block, using regex
---to check each line
---@param lnum integer? default to current line number
---@param buf integer? default to current buffer
---@return false|string? false if not in a code block; else the language of the code block
function M.in_codeblock_regex(lnum, buf)
  buf = buf or 0
  lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, lnum, false)
  local lang = false
  local in_codeblock = false
  local in_codeblock_next = false
  for _, line in ipairs(lines) do
    line = vim.trim(line)
    in_codeblock = in_codeblock_next
    if vim.startswith(line, '```') then
      lang = line:match('^```(%S+)')
      if not in_codeblock then
        in_codeblock_next = true
      else
        in_codeblock = false
        in_codeblock_next = false
      end
    end
  end
  return in_codeblock and lang or false
end

---Check if the current line is a markdown code block
---@param lnum integer? 1-based line index, default to current line number
---@param buf integer? default to current buffer
---@return false|string? false if not in a code block; else the language of the code block
function M.in_codeblock(lnum, buf)
  buf = buf or 0
  lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]
  if utils.ts.is_active(buf) then
    if
      not utils.ts.in_node('code_fence_content', {
        pos = { lnum - 1, 0 },
        bufnr = buf,
      })
    then
      return false
    end
    return utils.ts.lang({ lnum, 0 }, buf)
  end
  return M.in_codeblock_regex(lnum, buf)
end

---Check if cursor position is in a markdown inline code
---@param cursor integer[]? default to current cursor position
---@param buf integer? default to current buffer
---@return boolean
function M.in_codeinline(cursor, buf)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  buf = buf or 0
  local line =
    vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
  local idx = 0
  local inside = false
  while idx ~= cursor[2] do
    idx = idx + 1
    if line:sub(idx, idx) == '`' then
      inside = not inside
    end
  end
  return inside
end

---Returns whether the cursor is in a math zone
---@return boolean
function M.in_mathzone()
  return utils.ft.tex.in_mathzone()
end

---Returns whether the cursor is in normal zone
---(not in math zone or code block)
---@return boolean
function M.in_normalzone()
  return not M.in_mathzone() and not M.in_codeblock()
end

return M
