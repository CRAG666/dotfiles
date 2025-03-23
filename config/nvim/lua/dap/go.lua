local M = {}
local dap_utils = require('utils.dap')

---@type dapcache_t
local cache = dap_utils.new_cache()

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
    args = dap_utils.get_args(cache),
  },
  -- Works with go.mod packages and sub packages
  {
    type = 'delve',
    name = 'Debug test (go.mod)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
  {
    type = 'delve',
    name = 'Debug test (single test func)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
    args = function()
      local test_fn = vim.fn.expand('<cword>') ---@type string
      if not vim.startswith(test_fn, 'Test') then
        test_fn = vim.api.nvim_get_current_line():match('func%s+(Test%w*)')
          or ''
      end
      if not vim.startswith(test_fn, 'Test') then
        vim.ui.input({
          prompt = 'Enter test function name: ',
        }, function(input)
          test_fn = input
        end)
      end
      return {
        '-test.v',
        '-test.run',
        test_fn,
      }
    end,
  },
}

return M
