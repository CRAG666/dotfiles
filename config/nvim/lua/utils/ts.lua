local M = {}

---Returns whether treesitter is active in `buf`
---@param buf integer? default: current buffer
---@return boolean
function M.active(buf)
  if not buf or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if vim.treesitter.highlighter.active[buf] then
    return true
  end

  -- `vim.treesitter.get_parser()` can be slow for big files
  if not vim.b.bigfile and (pcall(vim.treesitter.get_parser, buf)) then
    return true
  end

  -- File is big or cannot get parser for buf
  return false
end

---Returns whether cursor is in a specific type of treesitter node
---@param ntype string|function(type: string): boolean type of node, or function to check node type
---@param opts vim.treesitter.get_node.Opts?
---@return boolean
function M.in_node(ntype, opts)
  if not M.active(opts and opts.bufnr) then
    return false
  end

  local node = vim.treesitter.get_node(opts)
  if not node then
    return false
  end

  if type(ntype) == 'string' then
    return node:type():match(ntype) ~= nil
  end

  return ntype(node:type())
end

return M
