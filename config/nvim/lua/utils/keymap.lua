local M = {}

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

---@param mode string|string[]
---@param prefix string
---@param maps table[] Each entry: { lhs_suffix, rhs, desc?, extra_opts? }
function M.pmaps(mode, prefix, maps)
  mode = mode or 'n'
  for _, map in ipairs(maps) do
    local opts = {}
    if map[3] then
      opts.desc = map[3]
    end
    if map[4] then
      opts = vim.tbl_extend('force', opts, map[4])
    end
    M.map(mode, prefix .. map[1], map[2], opts)
  end
end

---@param maps table[] Each entry: { mode?, prefix, maps }
function M.maps(maps)
  for _, map in ipairs(maps) do
    M.pmaps(map.mode or 'n', map.prefix, map.maps)
  end
end

---Map a key that loads `module` via `setup()` on first use.
---@param module string
---@param setup fun()
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param opts table?
function M.map_lazy(module, setup, mode, lhs, rhs, opts)
  M.map(mode, lhs, function()
    if not package.loaded[module] then
      setup()
    end
    if type(rhs) == 'function' then
      rhs()
    else
      vim.cmd(rhs)
    end
  end, opts)
end

---@param module string
---@param setup fun()
---@param mode string|string[]
---@param prefix string
---@param maps table[]
function M.maps_lazy(module, setup, mode, prefix, maps)
  mode = mode or 'n'
  for _, map in ipairs(maps) do
    local opts = {}
    if map[3] then
      opts.desc = map[3]
    end
    if map[4] then
      opts = vim.tbl_extend('force', opts, map[4])
    end
    M.map_lazy(module, setup, mode, prefix .. map[1], map[2], opts)
  end
end

return M
