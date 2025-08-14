local key = require('utils.keymap')
key.map_lazy(
  'dbee',
  function()
    vim.pack.add({ 'https://github.com/kndndrj/nvim-dbee' })
    require('dbee').setup({})
  end,
  'n',
  ';dm',
  function()
    require('dbee').toggle()
  end,
  { desc = '[d]atabase [m]ode' }
)
