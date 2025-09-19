local M = {}

local utils = require('utils')

---@type dapcache_t
local cache = utils.dap.new_cache()

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
      command = 'python3',
      args = { '-m', 'debugpy.adapter' },
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
    args = utils.dap.get_args(cache),
    pythonPath = function()
      return vim.fn.exepath('python3')
    end,
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
    console = 'integratedTerminal',
    module = function()
      -- Example test command: python3 -m pytest -s tests/test_xxx.py::test_xxx
      local test_cmd = utils.test.get_test_cmd()
      if not test_cmd then
        return
      end

      -- Extract module name, e.g. 'pytest'
      local test_cmd_args = utils.cmd.split(test_cmd)
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

      local test_cmd_args = utils.cmd.split(test_cmd)
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
  },
}

return M
