vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.textwidth = 120
vim.bo.expandtab = true
vim.bo.autoindent = true

-- lua lsp server
local util = require('null-ls.utils')
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
local lua_ls = {
  name = 'lua_ls',
  cmd = { 'lua-language-server' },
  root_patterns = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'selene.toml',
    'selene.yml',
  },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
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
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
        -- library = vim.api.nvim_get_runtime_file("", true),
        maxPreload = 2000,
        preloadFileSize = 50000,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      completion = { callSnippet = 'Both' },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
}
require('config.lsp').setup(lua_ls)
