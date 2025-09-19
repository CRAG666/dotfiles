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

require('core.defaults')
require('core.autocmds')
require('core.keymappings')

require('plugins.ui')
require('plugins.dev')
require('plugins.general')
require('plugins.modes')

vim.api.nvim_create_autocmd('FileType', {
  once = true,
  desc = 'Apply treesitter settings.',
  callback = function()
    require('plugins.ui.treesitter')
    require('core.treesitter')
  end,
})

local load = require('utils.load')

-- load.on_events('FileType', 'core.treesitter')
load.on_events('DiagnosticChanged', 'core.diagnostic')
load.on_events({ 'FileType', 'LspAttach' }, 'core.lsp')

require('plugins.modes.org').open_workspace()
