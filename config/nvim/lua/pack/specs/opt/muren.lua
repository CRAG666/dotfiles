return {
  src = 'https://github.com/AckslD/muren.nvim',
  data = {
    keys = {
      {
        mode = 'n',
        lhs = '<leader>rp',
        rhs = '<cmd>MurenToggle<cr>',
        opts = { desc = 'Search [r]eplace [p]attern' },
      },
    },
    cmds = { 'MurenToggle' },
    postload = function()
      require('muren').setup({})
    end,
  },
}
