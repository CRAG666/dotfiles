local key = require('utils.keymap')
key.maps_lazy(
  'grapple',
  function()
    vim.pack.add({ { src = 'https://github.com/cbochs/grapple.nvim' } })
  end,
  'n',
  '<leader>',
  {
    { 'm', '<cmd>Grapple toggle<cr>', '[m]ark file' },
    { "'", '<cmd>Grapple toggle_tags<cr>', 'Marked Files' },
    { '`', '<cmd>Grapple toggle_scopes<cr>', 'Grapple toggle scopes' },
    { 'j', '<cmd>Grapple cycle forward<cr>', 'Grapple cycle forward' },
    { 'k', '<cmd>Grapple cycle backward<cr>', 'Grapple cycle backward' },
  }
)

