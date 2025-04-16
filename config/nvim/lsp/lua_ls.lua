return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
  },
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'PLUGINS',
          'describe',
          'it',
          'before_each',
          'after_each',
        },
        disable = {
          'lowercase-global',
          'undefined-global',
          'unused-local',
          'unused-vararg',
          'trailing-space',
        },
      },
      completion = { callSnippet = 'Replace' },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
}
