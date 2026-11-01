local M = {}

M.adapter = function(cb)
  cb({
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = 'node',
      args = {
        vim.fs.joinpath(
          require('utils').dap.mise_where('github:microsoft/vscode-js-debug'),
          'src',
          'dapDebugServer.js'
        ),
        '${port}',
        '127.0.0.1',
      },
    },
  })
end

M.config = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    cwd = '${workspaceFolder}',
    console = 'integratedTerminal',
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach to process',
    processId = function()
      return require('dap.utils').pick_process({ filter = 'node' })
    end,
    cwd = '${workspaceFolder}',
  },
}

return M
