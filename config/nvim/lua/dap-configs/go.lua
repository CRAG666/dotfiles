local M = {}

local utils = require('utils')

---@type dapcache_t
local cache = utils.dap.new_cache()

M.adapter = function(callback, config)
  if config.mode == 'remote' and config.request == 'attach' then
    callback({
      type = 'server',
      host = config.host or '127.0.0.1',
      port = config.port or '38697',
    })
  else
    callback({
      type = 'server',
      port = '${port}',
      executable = {
        command = 'dlv',
        args = {
          'dap',
          '-l',
          '127.0.0.1:${port}',
          '--log',
          '--log-output=dap',
        },
        detached = vim.fn.has('win32') == 0,
      },
    })
  end
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
M.config = {
  {
    type = 'delve',
    name = 'Debug',
    request = 'launch',
    program = '${file}',
    args = utils.dap.get_args(cache),
  },
  -- Works with go.mod packages and sub packages
  {
    type = 'delve',
    name = 'Debug test (file)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
  {
    type = 'delve',
    name = 'Debug test (single method)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
    args = function()
      local test_cmd = utils.test.get_test_cmd()
      if not test_cmd then
        return
      end

      -- Transform "go test -v -failfast -run 'TestMain$' ./."
      -- to { '-test.v', '-test.failfast', '-test.run', 'TestMain$', './.' }
      -- See https://stackoverflow.com/a/67421231
      return vim
        .iter(utils.cmd.split(test_cmd))
        :map(function(arg)
          return (arg:gsub('^%-(%w+)', '-test.%1'))
        end)
        :totable()
    end,
  },
}

return M
