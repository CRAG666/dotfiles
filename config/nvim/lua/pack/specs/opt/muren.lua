return {
  src = 'https://github.com/AckslD/muren.nvim',
  data = {
    keys = {
      mode = { 'n', 'x' },
      lhs = '<leader>rp',
      opts = { desc = 'Search [r]eplace [s]tructure' },
    },
    cmds = { 'MurenToggle' },
    postload = function()
      require('muren').setup({})
      vim.keymap.set('n', '<leader>rp', '<cmd>MurenToggle<cr>')
    end,
  },
}
