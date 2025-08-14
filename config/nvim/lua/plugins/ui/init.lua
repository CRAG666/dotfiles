local fn = require('utils.fn')

require('plugins.ui.treesitter')
require('plugins.ui.catppuccin')
vim.pack.add({
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/DaikyXendo/nvim-material-icon',
})
require('plugins.ui.base')
fn.lazy_load('UIEnter', 'catppuccin', function()
  require('plugins.ui.noice')
  require('plugins.ui.gitsigns')
end)
