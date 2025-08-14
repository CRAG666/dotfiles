local key = require('utils.keymap')

local function setup_flash()
  vim.pack.add({
    'https://github.com/folke/flash.nvim',
  })
  require('flash').setup({})
end

key.maps_lazy('flash', setup_flash, { 'n', 'x', 'o' }, '', {
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
})

key.map_lazy('flash', setup_flash, 'o', 'r', function()
  require('flash').remote()
end, { desc = 'Remote Flash' })

key.map_lazy('flash', setup_flash, { 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })

key.map_lazy('flash', setup_flash, 'c', '<c-s>', function()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })
