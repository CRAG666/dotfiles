return {
  src = 'https://github.com/AckslD/muren.nvim',
  data = {
    keys = {
      {
        mode = 'n',
        lhs = '<leader>rp',
        opts = { desc = 'Search [r]eplace [p]attern' },
      },
    },
    cmds = { 'MurenToggle' },
    postload = function()
      require('muren').setup({})
      vim.keymap.set('n', '<leader>rs', '<cmd>MurenToggle<cr>')
    end,
  },
}
