---@type lsp_config_t
return {
  filetypes = { 'lua' },
  cmd = { 'lua-language-server' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
  },
  settings = {
    Lua = {
      hint = { enable = true },
      format = { enable = false }, -- use stylua for formatting
    },
  },
}
