local M = {}

---Returns whether treesitter is active in `buf`
---@param buf integer? default: current buffer
---@return boolean
function M.is_active(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local ok = pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft)
  return ok and true or false
end

---Returns whether cursor is in a specific type of treesitter node
---@param ntype string|function(type: string): boolean type of node, or function to check node type
---@param pos integer[]? 1,0-indexed position, default: current cursor position
---@param buf integer? default: current buffer
---@param mode string? default: current mode
---@return boolean
function M.in_tsnode(ntype, pos, buf, mode)
  pos = pos or vim.api.nvim_win_get_cursor(0)
  buf = buf or vim.api.nvim_get_current_buf()
  mode = mode or vim.api.nvim_get_mode().mode
  if not M.is_active(buf) then
    return false
  end
  local node = vim.treesitter.get_node {
    bufnr = buf,
    pos = {
      pos[1] - 1,
      pos[2] - (pos[2] >= 1 and mode:match "^i" and 1 or 0),
    },
  }
  if not node then
    return false
  end
  if type(ntype) == "string" then
    return node:type():match(ntype) ~= nil
  end
  return ntype(node:type())
end

return M
