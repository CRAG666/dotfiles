local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
---@type lsp_config_t
return {
  name = 'lua_ls',
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
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
        globals = {
          'vim',
          'PLUGINS',
          'describe',
          'it',
          'before_each',
          'after_each',
        },
      },
      telemetry = { enable = false },
      hint = { enable = true },
      format = { enable = false }, -- use stylua for formatting
    },
  },
}
