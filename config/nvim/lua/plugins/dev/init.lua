-- Load base dependencies
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

require('plugins.dev.base')

-- Load refactored plugins
require('plugins.dev.ai')
require('plugins.dev.term')
require('plugins.dev.blink')
require('plugins.dev.run_code')
-- require('plugins.dev.debug')
require('plugins.dev.neogen')
-- require('plugins.dev.refactoring')
-- require('plugins.dev.rest')
-- require('plugins.dev.template')
-- require('plugins.dev.test')
