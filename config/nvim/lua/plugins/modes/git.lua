local key = require('utils.keymap')
vim.pack.add({
  'https://github.com/SuperBo/fugit2.nvim',
  'https://github.com/chrisgrieser/nvim-tinygit',
})

require('fugit2').setup({
  width = 100,
})

key.map('n', '<leader>gm', '<cmd>Fugit2<cr>', { desc = 'Git Mode' })
key.map('n', '<leader>gg', '<cmd>Fugit2Graph<cr>', { desc = 'Git Graph' })
