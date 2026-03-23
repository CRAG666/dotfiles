---@type my.lsp.config
return {
  filetypes = { 'lua' },
  cmd = { 'lua-language-server' },
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
      hint = { enable = true },
      format = { enable = false }, -- use stylua for formatting
    },
  },
}
