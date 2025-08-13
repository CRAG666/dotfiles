-- Desabilitar plugins nativos
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
}

for _, plugin in ipairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

require('plugins.dev')
require('plugins.ui')
require('plugins.general')
require('plugins.modes')
