return {
  src = 'https://github.com/SuperBo/fugit2.nvim',
  data = {
    deps = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
      { src = 'https://github.com/chrisgrieser/nvim-tinygit' },
      {
        src = 'https://github.com/kyazdani42/nvim-web-devicons',
        data = { optional = false },
      },
    },
    keys = {
      { mode = 'n', lhs = '<leader>gm', opts = { desc = 'Git Mode' } },
      { mode = 'n', lhs = '<localleader>gg', opts = { desc = 'Git Graph' } },
    },
    cmds = { 'Fugit2', 'Fugit2Graph' },
    postload = function()
      require('fugit2').setup({ width = 100 })
      vim.keymap.set('n', '<leader>gm', '<cmd>Fugit2<cr>')
      vim.keymap.set('n', '<localleader>gg', '<cmd>Fugit2Graph<cr>')
    end,
  },
}
