local M = {}

local utils = require('utils')

---@type dap.cache
local cache = utils.dap.new_cache()

---Python of the active or project `.venv`, so the debuggee sees its packages
---@return string
local function python_path()
  local venv = vim.env.VIRTUAL_ENV
    or vim.fs.joinpath(vim.fn.getcwd(0), '.venv')
  local python = vim.fs.joinpath(venv, 'bin', 'python')
  return vim.fn.executable(python) == 1 and python or vim.fn.exepath('python3')
end

M.adapter = function(cb, config)
  if config.request == 'attach' then
    local port = (config.connect or config).port or '5678'
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(
        port,
        '`connect.port` is required for a python `attach` configuration'
      ),
      host = host,
      options = {
        source_filetype = 'python',
      },
    })
  else
    cb({
      type = 'executable',
      command = 'debugpy-adapter',
      options = {
        source_filetype = 'python',
      },
    })
  end
end

M.config = {
  {
    type = 'debugpy',
    name = 'Launch file',
    request = 'launch',
    program = '${file}',
    -- Show program output in console instead of REPL, from
    -- https://www.reddit.com/r/neovim/comments/14f820c/comment/jp6fr8f/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    console = 'integratedTerminal',
    justMyCode = function()
      return vim.fn.confirm(
        'Allow debugpy to step into external functions?',
        '&Yes\n&No',
        2
      ) ~= 1
    end,
    args = utils.dap.get_args(cache),
    pythonPath = python_path,
    -- Fix debugpy cannot find local python modules, assuming cwd has been
    -- set to project root, see https://stackoverflow.com/a/63271966
    env = function()
      return { PYTHONPATH = vim.fn.getcwd(0) }
    end,
  },
  {
    type = 'debugpy',
    name = 'Debug test',
    request = 'launch',
    pythonPath = python_path,
    console = 'integratedTerminal',
    justMyCode = function()
      return vim.fn.confirm(
        'Allow debugpy to step into external functions?',
        '&Yes\n&No',
        2
      ) ~= 1
    end,
    module = function()
      -- Example test command: python3 -m pytest -s tests/test_xxx.py::test_xxx
      local test_cmd = utils.test.get_test_cmd()
      if not test_cmd then
        return
      end

      -- Extract module name, e.g. 'pytest'
      local test_cmd_args = require('dap.utils').splitstr(test_cmd)
      for i, arg in ipairs(test_cmd_args) do
        if arg == '-m' then
          return test_cmd_args[i + 1]
        end
      end
    end,
    args = function()
      local test_cmd = utils.test.get_test_cmd()
      if not test_cmd then
        return
      end

      local test_cmd_args = require('dap.utils').splitstr(test_cmd)
      for i, arg in ipairs(test_cmd_args) do
        if arg == '-m' then
          return vim.iter(test_cmd_args):skip(i + 1):totable()
        end
      end
    end,
    env = function()
      return { PYTHONPATH = vim.fn.getcwd(0) }
    end,
  },
  {
    type = 'debugpy',
    name = 'Attach to running debugpy',
    request = 'attach',
    console = 'integratedTerminal',
    justMyCode = function()
      return vim.fn.confirm(
        'Allow debugpy to step into external functions?',
        '&Yes\n&No',
        2
      ) ~= 1
    end,
  },
}

return M
