vim.pack.add({
  'https://github.com/nvzone/volt',
  'https://github.com/nvzone/typr',
  'https://github.com/m4xshen/hardtime.nvim',
})

local fn = require('utils.fn')
fn.lazy_load('UIEnter', 'typr', function()
  require('typr').setup()
  require('hardtime').setup()
end)

require('plugins.modes.database')
require('plugins.modes.git')
require('plugins.modes.motion')
-- require('plugins.modes.org')
