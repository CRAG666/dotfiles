local key = require('utils.keymap')
vim.pack.add({
  'https://github.com/folke/flash.nvim',
})
local flash = require('flash')
flash.setup({})
key.map({ 'n', 'x', 'o' }, 's', flash.jump, { desc = 'Flash' })
key.map(
  { 'n', 'x', 'o' },
  'S',
  flash.treesitter,
  { desc = 'Flash Treesitter' }
)
key.map({ 'o' }, 'r', flash.remote, { desc = 'Remote Flash' })
key.map(
  { 'o', 'x' },
  'R',
  flash.treesitter_search,
  { desc = 'Treesitter Search' }
)
key.map({ 'c' }, '<c-s>', flash.toggle, { desc = 'Toggle Flash Search' })
