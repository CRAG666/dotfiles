local M = {}

local utils = require('utils')

---@type dapcache_t
local cache = utils.dap.new_cache()

M.adapter = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.exepath('codelldb'), -- must be full path
    args = { '--port', '${port}' },
  },
}

M.config = {
  {
    type = 'codelldb',
    name = 'Launch file',
    request = 'launch',
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    program = utils.dap.get_prog(cache),
    args = utils.dap.get_args(cache),
  },
}

return M
