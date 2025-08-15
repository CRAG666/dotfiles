local key = require('utils.keymap')

vim.opt_local.list = true
vim.opt_local.number = true
vim.opt_local.wrap = false
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

vim.pack.add({ 'https://github.com/hat0uma/csvview.nvim' })

require('csvview').setup({
  view = {
    display_mode = 'border',
  },
})

require('csvview').toggle()
