local M = {}

M.adapter = {
  type = 'executable',
  command = vim.fn.exepath('netcoredbg'),
  args = { '--interpreter=vscode' },
}

M.config = {
  {
    type = 'coreclr',
    name = 'Launch',
    request = 'launch',
    cwd = '${workspaceFolder}',
    program = function()
      return require('dap.utils').pick_file({
        filter = '/bin/.*%.dll$',
        executables = false,
      })
    end,
  },
  {
    type = 'coreclr',
    name = 'Attach to process',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
}

return M
