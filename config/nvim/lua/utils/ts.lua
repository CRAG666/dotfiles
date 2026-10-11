local M = {}

---Returns whether treesitter is active in `buf`
---@param buf integer? default: current buffer
---@return boolean
function M.is_active(buf)
  return vim.treesitter.highlighter.active[vim._resolve_bufnr(buf)] ~= nil
end

local ts_get_node = vim.treesitter.get_node

---Cursor position (0-indexed) of the current window, shifted to the character
---before the cursor in insert mode
---@return integer[]
local function cursor_pos()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return {
    cursor[1] - 1,
    cursor[2]
      - (cursor[2] >= 1 and vim.startswith(vim.fn.mode(), 'i') and 1 or 0),
  }
end

---Wrapper of `vim.treesitter.get_node()` that fixes the cursor pos in
---insert mode
---@param opts vim.treesitter.get_node.Opts?
function M.get_node(opts)
  opts = opts or {}

  -- According to `:h vim.treesitter.get_node()`, `pos` fallback to current
  -- cursor position is not given, however it is REQUIRED if `opts.bufnr` is
  -- given and is not the current buffer, so don't fix `opts.pos` if
  -- 1. `opts.pos` is provided, or
  -- 2. `opts.bufnr` refers to a non-current buffer
  if
    opts.pos
    or opts.bufnr
      and opts.bufnr ~= 0
      and opts.bufnr ~= vim.api.nvim_get_current_buf()
  then
    return ts_get_node(opts)
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
  opts.pos = cursor_pos()

  return ts_get_node(opts)
end

---@class ts.get_node.opts : vim.treesitter.get_node.Opts
---@field depth? integer

---`find_node()` results for the current buffer state and cursor position,
---snippet conditions query the same nodes many times per key
---@type { state: string?, parsed: boolean, nodes: table<string, TSNode|false> }
local find_node_cache = { parsed = false, nodes = {} }

---Returns whether cursor is in a specific type of treesitter node
---@param types string|string[]|fun(types: string|string[]): boolean type of node, or function to check node type
---@param opts ts.get_node.opts?
---@return TSNode?
function M.find_node(types, opts)
  local buf = opts and opts.bufnr

  if not M.is_active(buf) then
    return
  end

  local parser = vim.treesitter.get_parser(buf)
  if not parser then
    return
  end

  -- Only cache lookups at the cursor of the current buffer with plain types
  local cache_key ---@type string?
  if
    not vim.is_callable(types) and not (opts and (opts.bufnr or opts.pos))
  then
    local cur_buf = vim.api.nvim_get_current_buf()
    local pos = cursor_pos()
    local state = table.concat({
      cur_buf,
      vim.api.nvim_buf_get_changedtick(cur_buf),
      pos[1],
      pos[2],
    }, ':')
    if find_node_cache.state ~= state then
      find_node_cache = { state = state, parsed = false, nodes = {} }
    end
    cache_key = table.concat({
      type(types) == 'table' and table.concat(types, ',') or types,
      tostring(opts and opts.ignore_injections),
      tostring(opts and opts.depth),
    }, ':')
    local node = find_node_cache.nodes[cache_key]
    if node ~= nil then
      return node or nil
    end
  end

  ---Check if given node type matches any of the types given in `types`
  ---@type fun(t: string): boolean?
  local check_type_match = vim.is_callable(types)
      and function(nt)
        return types(nt)
      end
    or function(nt)
      if type(types) == 'string' then
        types = { types }
      end
      return vim.iter(types):any(function(t)
        return nt:match(t)
      end)
    end

  ---@return TSNode?
  local function reverse_traverse()
    local node = M.get_node(opts)
    local depth = opts and opts.depth or math.huge
    while node and depth > 0 do
      local nt = node:type() -- current node type
      if check_type_match(nt) then
        return node
      end
      node = node:parent()
      depth = depth - 1
    end
  end

  ---@param node TSNode?
  ---@return TSNode?
  local function cached(node)
    if cache_key then
      find_node_cache.nodes[cache_key] = node or false
    end
    return node
  end

  local node = reverse_traverse()
  if node or parser:is_valid() or (cache_key and find_node_cache.parsed) then
    return cached(node)
  end

  -- If the node wasn't found, re-parse the current tree and try again
  --
  -- Note: In the previous lookup, we traverse the original tree regardless
  -- of whether it is valid or not, because re-parsing an edited region can
  -- introduce `ERROR` nodes, potentially preventing node lookup even if the
  -- cursor is within the node boundaries
  local lnum = vim.fn.line('.')
  parser:parse({ lnum - 1, lnum })
  if cache_key then
    find_node_cache.parsed = true
  end
  return cached(reverse_traverse())
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

  buf = vim._resolve_bufnr(buf)
  local has_parser, parser = pcall(
    vim.treesitter.get_parser,
    buf,
    vim.filetype.match({
      buf = buf,
    })
  )
  if not has_parser or not parser then
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
