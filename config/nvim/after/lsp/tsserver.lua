---@type lsp.config
return {
  filetypes = {
    'typescript',
    'javascript',
    'typescriptreact',
    'javascriptreact',
  },
  cmd = {
    'typescript-language-server',
    '--stdio',
  },
  root_markers = {
    {
      'tsconfig.json',
      'jsconfig.json',
    },
    { 'package.json' },
  },
  init_options = {
    hostInfo = 'neovim',
  },
}
