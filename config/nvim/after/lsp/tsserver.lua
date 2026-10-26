-- TypeScript 5 comes from mise's npm:typescript, outside the server's own
-- node_modules; a workspace TypeScript still wins over this fallback
local tsserver = vim.fn.exepath('tsserver')

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
    tsserver = tsserver ~= '' and {
      fallbackPath = vim.fs.joinpath(
        vim.fs.dirname(vim.fs.dirname(tsserver)),
        'typescript',
        'lib'
      ),
    } or nil,
  },
}
