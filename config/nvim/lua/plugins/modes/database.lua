local key = require('utils.keymap')
local function setup()
  vim.pack.add({ 'https://github.com/kndndrj/nvim-dbee' })
  require('dbee').setup({})
end
key.map_lazy('dbee', setup, 'n', ';dm', function()
  require('dbee').toggle()
end, { desc = '[d]atabase [m]ode' })
