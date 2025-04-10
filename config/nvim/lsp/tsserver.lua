return {
  name = 'tsserver',
  cmd = { 'typescript-language-server', '--stdio' },
  init_options = { hostInfo = 'neovim' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
}
