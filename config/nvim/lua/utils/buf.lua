local M = {}

---Check if a buffer is empty
---@param buf integer? default to current buffer
---@return boolean
function M.is_empty(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  return line_count == 0
    or line_count == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
end

return M
