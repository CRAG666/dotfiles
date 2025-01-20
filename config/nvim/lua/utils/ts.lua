local M = {}

---Only checks whether treesitter highlighting is active in `buf`
---Should be faster than `utils.ts.is_active()`
---@param buf integer? default: current buffer
---@return boolean
function M.hl_is_active(buf)
  if not buf or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  return vim.treesitter.highlighter.active[buf] ~= nil
end

---Returns whether treesitter is active in `buf`
---@param buf integer? default: current buffer
---@return boolean
function M.is_active(buf)
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
  if not M.is_active(opts and opts.bufnr) then
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

---Get language at given buffer position, useful in files with injected syntax
---e.g. markdown
---Source: `from_cursor_pos()` in `lua/luasnip/extras/filetype_functions.lua`
---@param pos { [1]: integer, [2]: integer }? (1, 0)-indexed cursor position
---@param buf integer?
---@return string?
function M.lang(pos, buf)
  if buf and not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  buf = buf or vim.api.nvim_get_current_buf()
  local has_parser, parser = pcall(
    vim.treesitter.get_parser,
    buf,
    vim.filetype.match({
      buf = buf,
    })
  )
  if not has_parser then
    return
  end

  pos = pos or vim.api.nvim_win_get_cursor(0)
  return parser
    :language_for_range({
      pos[1] - 1,
      pos[2],
      pos[1] - 1,
      pos[2],
    })
    :lang()
end

return M
