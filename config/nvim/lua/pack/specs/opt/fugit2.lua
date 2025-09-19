return {
  src = 'https://github.com/SuperBo/fugit2.nvim',
  data = {
    deps = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
      { src = 'https://github.com/chrisgrieser/nvim-tinygit' },
    },
    keys = {
      { mode = 'n', lhs = '<leader>gm' },
      { mode = 'n', lhs = '<leader>gg' },
    },
    cmds = { 'Fugit2', 'Fugit2Graph' },
    postload = function()
      require('fugit2').setup({ width = 100 })
      vim.keymap.set('n', '<leader>gm', '<cmd>Fugit2<cr>', { desc = 'Git Mode' })
      vim.keymap.set('n', '<leader>gg', '<cmd>Fugit2Graph<cr>', { desc = 'Git Graph' })
    end,
  },
}