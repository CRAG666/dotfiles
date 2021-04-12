-- Map leader to space
vim.g.mapleader = ' '
require('plugs')
require('settings')
-- Python documentation
vim.g.pydocstring_formatter = 'google'
require('config')
require('keymappings')
require('plugins.statusline')
-- source <sfile>:h/init/func.vim
-- source <sfile>:h/init/ignore.vim
