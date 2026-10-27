-- TypeScript 7 (native), language server built into the compiler
---@type lsp.config
return {
  filetypes = {
    'typescript',
    'javascript',
    'typescriptreact',
    'javascriptreact',
  },
  cmd = { 'tsc', '--lsp', '--stdio' },
  root_markers = {
    {
      'tsconfig.json',
      'jsconfig.json',
    },
    { 'package.json' },
  },
  settings = {
    ['js/ts'] = {
      inlayHints = {
        parameterNames = {
          enabled = 'literals',
          suppressWhenArgumentMatchesName = true,
        },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}
