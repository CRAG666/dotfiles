return {
  src = 'https://github.com/mbbill/undotree',
  data = {
    keys = {
      {
        mode = 'n',
        lhs = '<leader>ut',
        opts = { desc = '[U]ndotree' },
      },
    },
    cmds = { 'UndotreeToggle' },
    postload = function()
      vim.keymap.set('n', 'ut','<cmd>UndotreeToggle<cr>')
    end
  },
}
