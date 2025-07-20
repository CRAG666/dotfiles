local M = {}
local dap_utils = require('utils.dap')

---@type dapcache_t
local cache = dap_utils.new_cache()

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
    program = dap_utils.get_prog(cache),
    args = dap_utils.get_args(cache),
  },
}

return M
