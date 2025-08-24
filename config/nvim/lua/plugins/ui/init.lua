local fn = require('utils.fn')

vim.pack.add({
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/DaikyXendo/nvim-material-icon',
})

fn.lazy_load('VimEnter', 'noice', function()
  require('plugins.ui.noice')
  require('plugins.ui.gitsigns')
  require('plugins.ui.catppuccin')
  require('plugins.ui.quicker')
end)

require('plugins.ui.base')
require('plugins.ui.markup')
