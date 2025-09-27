return {
  src = 'https://github.com/kndndrj/nvim-dbee',
  data = {
    keys = {
      mode = 'n',
      lhs = ';dm',
    },
    cmds = { 'Dbee' },
    postload = function()
      require('dbee').setup({})
      vim.keymap.set('n', ';dm', function()
        require('dbee').toggle()
      end, { desc = '[d]atabase [m]ode' })
    end,
  },
}
