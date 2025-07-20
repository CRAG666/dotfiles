local M = {}
local dap_utils = require('utils.dap')

---@type dapcache_t
local cache = dap_utils.new_cache()

M.adapter = {
  name = 'bashdb',
  type = 'executable',
  command = 'node',
  args = {
    vim.fs.joinpath(
      vim.fn.stdpath('data') --[[@as string]],
      'vscode-bash-debug/extension/out/bashDebug.js'
    ),
  },
}

M.config = {
  {
    type = 'bashdb',
    request = 'launch',
    name = 'Launch file',
    showDebugOutput = true,
    pathBashdb = vim.fs.joinpath(
      vim.fn.stdpath('data') --[[@as string]],
      'vscode-bash-debug/extension/bashdb_dir/bashdb'
    ),
    pathBashdbLib = vim.fs.joinpath(
      vim.fn.stdpath('data') --[[@as string]],
      '/vscode-bash-debug/extension/bashdb_dir/'
    ),
    trace = true,
    file = '${file}',
    program = '${file}',
    cwd = '${workspaceFolder}',
    pathCat = 'cat',
    pathBash = '/bin/bash',
    pathMkfifo = 'mkfifo',
    pathPkill = 'pkill',
    env = {},
    terminalKind = 'integrated',
    args = dap_utils.get_args(cache),
  },
}

return M
