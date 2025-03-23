vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.textwidth = 0
vim.bo.autoindent = true
vim.bo.smartindent = true

local root_patterns = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
}
local pyright = {
  name = 'basedpyright',
  cmd = { 'basedpyright-langserver', '--stdio' },
  root_patterns = root_patterns,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
      },
    },
  },
  single_file_support = true,
}

local ruff_lsp = {
  name = 'ruff-lsp',
  cmd = { 'ruff', 'server' },
  single_file_support = true,
  root_patterns = root_patterns,
  init_options = {
    settings = {
      args = { '--line-length=180' },
    },
  },
}
-- require("config.lsp").setup(pyright, function(client, ...)
--   client.server_capabilities.hoverProvider = false
-- end)
require('config.lsp').setup(pyright)
require('config.lsp').setup(ruff_lsp)
