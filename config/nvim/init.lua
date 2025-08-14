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
require('config.keymappings')
require('config.autocmds')
require('plugins')
