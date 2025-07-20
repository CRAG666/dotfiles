local M = {}
local dap_utils = require('utils.dap')

---@type dapcache_t
local cache = dap_utils.new_cache()

M.adapter = function(cb, config)
  if config.request == 'attach' then
    local port = (config.connect or config).port
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
    args = dap_utils.get_args(cache),
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
    module = function()
      -- Example test command: python3 -m pytest -s tests/test_xxx.py::test_xxx
      local test_cmd = require('utils.test').get_test_cmd()
      if not test_cmd then
        return
      end
      -- Extract 'pytest'
      return test_cmd:match('.*python3?.*%s+%-m%s+(%S+)')
    end,
    args = function()
      local test_cmd = require('utils.test').get_test_cmd()
      if not test_cmd then
        return
      end
      -- HACK: cannot handle escaped string in args, e.g.
      -- 'test_file\ with_spaces' will be split incorrectly
      return vim.split(test_cmd:gsub('.*python3?.*%s+%-m%s+%S+%s+', ''), ' ', {
        trimempty = true,
      })
    end,
    env = function()
      return { PYTHONPATH = vim.fn.getcwd(0) }
    end,
  },
}

return M
