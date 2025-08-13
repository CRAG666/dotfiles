local key = require('utils.keymap')
vim.pack.add({
  'https://github.com/SuperBo/fugit2.nvim',
  'https://github.com/chrisgrieser/nvim-tinygit',
})

key.maps_lazy(
  'fugit2',
  require('utils.fn').setup('fugit2', { width = 100 }),
  'n',
  '<leader>g',
  {
    { 'm', 'Fugit2', 'Git Mode' },
    { 'g', 'Fugit2Graph', 'Git Graph' },
  }
)
