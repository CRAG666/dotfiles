vim.pack.add({ 'https://github.com/kndndrj/nvim-dbee' })
local key = require('utils.keymap')
key.map_lazy(
  'dbee',
  require('utils.fn').setup('dbee', {}),
  'n',
  ';dm',
  function()
    require('dbee').toggle()
  end,
  { desc = '[d]atabase [m]ode' }
)
