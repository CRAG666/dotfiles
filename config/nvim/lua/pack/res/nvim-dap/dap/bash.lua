local M = {}

local utils = require('utils')

---@type dap.cache
local cache = utils.dap.new_cache()

local function bash_debug_path(...)
  return vim.fs.joinpath(
    utils.dap.mise_where('github:rogalmic/vscode-bash-debug'),
    'extension',
    ...
  )
end

M.adapter = function(cb)
  cb({
    type = 'executable',
    command = 'node',
    args = { bash_debug_path('out', 'bashDebug.js') },
  })
end

M.config = {
  {
    type = 'bashdb',
    request = 'launch',
    name = 'Launch file',
    showDebugOutput = true,
    pathBashdb = function()
      return bash_debug_path('bashdb_dir', 'bashdb')
    end,
    pathBashdbLib = function()
      return bash_debug_path('bashdb_dir')
    end,
    trace = true,
    file = '${file}',
    program = '${file}',
    cwd = '${workspaceFolder}',
    pathCat = 'cat',
    pathBash = vim.fn.exepath('bash'),
    pathMkfifo = 'mkfifo',
    pathPkill = 'pkill',
    env = {},
    terminalKind = 'integrated',
    args = utils.dap.get_args(cache),
  },
}

return M
