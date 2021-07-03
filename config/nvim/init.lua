vim.g.mapleader = ' '
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 3
vim.g.netrw_winsize = 25
require('plugs')
require('settings')
require('colorscheme')
vim.g.pydocstring_formatter = 'google'
require('keymappings')
require('statusline')
require('config')
