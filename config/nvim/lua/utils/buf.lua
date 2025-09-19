local M = {}

---Check if a buffer is empty
---@param buf integer? default to current buffer
---@return boolean
function M.is_empty(buf)
  buf = vim._resolve_bufnr(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  return line_count == 0
    or line_count == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
end

---Get text within range in given buffer
---@param buf integer?
---@param start integer[] 0-based (line, col)
---@param finish integer[] 0-based (line, col), end-exclusive
---@return string[] lines text in range
function M.range(buf, start, finish)
  buf = vim._resolve_bufnr(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return {}
  end

  local lines = vim.api.nvim_buf_get_lines(buf, start[1], finish[1] + 1, false)
  local num_lines = #lines
  if num_lines == 0 then -- invalid range or empty buffer
    return lines
  end

  lines[num_lines] = lines[num_lines]:sub(1, finish[2])
  lines[1] = lines[1]:sub(start[2] + 1)

  return lines
end

return M
