return {
  src = 'https://github.com/mbbill/undotree',
  data = {
    keys = {
      {
        mode = 'n',
        lhs = '<leader>ut',
        rhs = '<cmd>UndotreeToggle<cr>',
        opts = { desc = '[U]ndotree' },
      },
    },
    cmds = { 'UndotreeToggle' },
  },
}