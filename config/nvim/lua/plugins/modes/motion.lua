local key = require('utils.keymap')
vim.pack.add({
  'https://github.com/folke/flash.nvim',
})

key.maps_lazy(
  'flash',
  require('utils.fn').setup('fash', {}),
  { 'n', 'x', 'o' },
  '',
  {
    {
      's',
      function()
        require('flash').jump()
      end,
      'Flash',
    },
    {
      'S',
      function()
        require('flash').treesitter()
      end,
      'Flash Treesitter',
    },
  }
)

key.map_lazy(
  'flash',
  require('utils.fn').setup('fash', {}),
  'o',
  'r',
  function()
    require('flash').remote()
  end,
  { desc = 'Remote Flash' }
)

key.map_lazy(
  'flash',
  require('utils.fn').setup('fash', {}),
  { 'o', 'x' },
  'R',
  function()
    require('flash').treesitter_search()
  end,
  { desc = 'Treesitter Search' }
)

key.map_lazy(
  'flash',
  require('utils.fn').setup('fash', {}),
  'c',
  '<c-s>',
  function()
    require('flash').toggle()
  end,
  { desc = 'Toggle Flash Search' }
)
