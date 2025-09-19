if vim.env.NVIM_NO3RD then
  return
end

local utils = require('utils')

local config_path = vim.fn.stdpath('config') --[[@as string]]
local specs_start_path = vim.fs.joinpath(config_path, 'lua/pack/specs/start')
local specs_opt_path = vim.fs.joinpath(config_path, 'lua/pack/specs/opt')

---@param path string
---@return vim.pack.Spec[]
local function collect_specs(path)
  local specs = {} ---@type vim.pack.Spec[]
  for spec in vim.fs.dir(path) do
    table.insert(specs, dofile(vim.fs.joinpath(path, spec)))
  end
  return specs
end

-- Load and manage all plugin specs on startup upon opening a file
if vim.fn.argc(-1) > 0 then
  utils.pack.add(
    vim.list_extend(
      collect_specs(specs_start_path),
      collect_specs(specs_opt_path)
    )
  )
  return
end

-- Defer loading plugin specs in `opt` if no files are given
-- Specs under `start` are always loaded on startup
utils.pack.add(collect_specs(specs_start_path))
utils.load.on_events(
  'UIEnter',
  'my.pack.load_opt',
  vim.schedule_wrap(function()
    utils.pack.add(collect_specs(specs_opt_path))
  end)
)
utils.load.on_events(
  { 'CmdUndefined', 'SessionLoadPost', 'FileType' },
  'my.pack.load_opt',
  function()
    utils.pack.add(collect_specs(specs_opt_path))
  end
)
