local key = require('utils.keymap')

key.maps_lazy(
  'fugit2',
  function()
    vim.pack.add({
      'https://github.com/SuperBo/fugit2.nvim',
      'https://github.com/chrisgrieser/nvim-tinygit',
    })
    require('fugit2').setup({ width = 100 })
  end,
  'n',
  '<leader>g',
  {
    { 'm', 'Fugit2', 'Git Mode' },
    { 'g', 'Fugit2Graph', 'Git Graph' },
  }
)
