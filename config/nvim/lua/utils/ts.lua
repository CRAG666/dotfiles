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

---Wrapper of `vim.treesitter.get_node()` that fixes the cursor pos in
---insert mode
---@param opts vim.treesitter.get_node.Opts?
function M.get_node(opts)
  return vim.treesitter.get_node({
    -- According to `:h vim.treesitter.get_node()`, `pos` fallback to current
    -- cursor position is not given, however it is REQUIRED if `opts.bufnr` is
    -- given and is not the current buffer
    pos = (function()
      -- 1. If `opts.pos` is provided, use it as-is
      -- 2. If `opts.bufnr` refers to a non-current buffer, pass `opts.pos` to
      --    `vim.treesitter.get_node()` regardless if it's nil (will error if
      --    nil)
      if
        opts
        and (
          opts.pos
          or opts.bufnr
            and opts.bufnr ~= 0
            and opts.bufnr ~= vim.api.nvim_get_current_buf()
        )
      then
        return opts.pos
      end

      -- Fix cursor position in insert mode -- if currently in insert mode,
      -- shift `pos` left by one character because we care about the node
      -- before cursor instead of under it since we are inserting text
      -- before cursor instead of after it, e.g. if our cursor is in between
      -- node1 and node2 in insert mode, like this:
      --
      -- <node1>|<node2>
      --
      -- where `|` is the cursor currently on node2, we will want to get node1
      -- (node before cursor) instead of node2 (node after/covered by cursor)
      --
      -- Also useful when the cursor is at the end of line and is not on any
      -- text (and of course treesitter nodes)
      local cursor = opts and opts.pos or vim.api.nvim_win_get_cursor(0)
      return {
        cursor[1] - 1,
        cursor[2]
          - (cursor[2] >= 1 and vim.startswith(vim.fn.mode(), 'i') and 1 or 0),
      }
    end)(),
  })
end

---Returns whether cursor is in a specific type of treesitter node
---@param types string|string[]|fun(types: string|string[]): boolean type of node, or function to check node type
---@param opts vim.treesitter.get_node.Opts?
---@return boolean
function M.in_node(types, opts)
  if not M.is_active(opts and opts.bufnr) then
    return false
  end

  local node = M.get_node(opts)
  if not node then
    return false
  end

  local nt = node:type() -- current node type
  if vim.is_callable(types) then
    return types(nt)
  end

  if type(types) == 'string' then
    types = { types }
  end
  local result = vim.iter(types):any(function(t)
    return nt:match(t)
  end)
  return result
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
