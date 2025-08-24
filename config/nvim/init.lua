vim.loader.enable()
vim.validate = function() end

local disabled_built_ins = {
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'gzip',
  'zip',
  'zipPlugin',
  'tar',
  'tarPlugin',
  'getscript',
  'getscriptPlugin',
  'vimball',
  '2html_plugin',
  'logiPat',
  'rrhelper',
  'spellfile_plugin',
  'matchit',
  'compiler',
  'ftplugin',
  'rplugin',
  'synmenu',
  'syntax',
  'tohtml',
  'tutor',
  'tutor_mode_plugin',
}

for _, plugin in ipairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

require('config.defaults')
require('config.autocmds')
require('config.keymappings')

require('plugins.ui')
require('plugins.dev')
require('plugins.general')
require('plugins.modes')

local key = require('utils.keymap')

key.map('n', '<leader>pu', vim.pack.update, { desc = 'Update Plugins' })
key.map('n', '<leader>pi', vim.pack.get, { desc = 'Plugins Info' })

vim.api.nvim_create_autocmd('FileType', {
  once = true,
  desc = 'Apply treesitter settings.',
  callback = function()
    require('plugins.ui.treesitter')
    require('config.treesitter')
  end,
})

vim.api.nvim_create_autocmd({ 'FileType', 'LspAttach' }, {
  once = true,
  desc = 'Apply lsp settings.',
  callback = function()
    require('config.lsp')
  end,
})

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  once = true,
  desc = 'Apply diagnostic settings.',
  callback = function()
    require('config.diagnostic')
  end,
})

require('plugins.modes.org').open_workspace()
