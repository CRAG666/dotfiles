local M = {}

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.pmaps(mode, prefix, maps)
  mode = mode or 'n'
  vim.tbl_map(function(map)
    local opts = {}
    if map[3] then
      opts.desc = map[3]
    end
    if map[4] then
      opts = vim.tbl_extend('force', opts, map[4])
    end
    M.map(mode, prefix .. map[1], map[2], opts)
  end, maps)
end

function M.maps(maps)
  for _, map in pairs(maps) do
    local mode = map.mode or 'n'
    M.pmaps(mode, map.prefix, map.maps)
  end
end

function M.map_lazy(module, setup, mode, lhs, rhs, opts)
  M.map(mode, lhs, function()
    local ok, _ = pcall(require, module)
    vim.keymap.del(mode, lhs)
    if not ok then
      setup()
    end
    local fn
    if type(rhs) == 'function' then
      fn = rhs
    else
      fn = function()
        vim.cmd(rhs)
      end
    end
    fn()
    M.map(mode, lhs, fn, opts)
  end, opts)
end

function M.maps_lazy(module, setup, mode, prefix, maps)
  mode = mode or 'n'
  vim.tbl_map(function(map)
    local opts = {}
    if map[3] then
      opts.desc = map[3]
    end
    if map[4] then
      opts = vim.tbl_extend('force', opts, map[4])
    end
    local key = prefix .. map[1]
    M.map_lazy(module, setup, mode, key, map[2], opts)
  end, maps)
end

---Set abbreviation that only expand when the trigger is at the position of
---a command
---@param trig string|{ [1]: string, [2]: string }
---@param command string
---@param opts table?
function M.command_abbrev(trig, command, opts)
  -- Map a range, first one if command short name,
  -- second one if command full name
  if type(trig) == 'table' then
    local trig_short = trig[1]
    local trig_full = trig[2]
    for i = #trig_short, #trig_full do
      local cmd_part = trig_full:sub(1, i)
      M.command_abbrev(cmd_part, command)
    end
    return
  end
  vim.keymap.set('ca', trig, function()
    return vim.fn.getcmdcompltype() == 'command' and command or trig
  end, vim.tbl_deep_extend('keep', { expr = true }, opts or {}))
end

---Set keymap that only expand when the trigger is at the position of
---a command
---@param trig string
---@param command string
---@param opts table?
function M.command_map(trig, command, opts)
  vim.keymap.set('c', trig, function()
    return vim.fn.getcmdcompltype() == 'command' and command or trig
  end, vim.tbl_deep_extend('keep', { expr = true }, opts or {}))
end

return M
