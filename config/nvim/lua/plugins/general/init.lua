vim.pack.add({ { src = 'https://github.com/chaoren/vim-wordmotion' } })
vim.pack.add({ { src = 'https://github.com/kylechui/nvim-surround' } })

require('nvim-surround').setup({})
require('plugins.general.pickers')
require('plugins.general.autopair')
require('plugins.general.harpoon')
require('plugins.general.mini')
require('plugins.general.search_and_replace')

