---@type pack.spec
return {
  src = 'https://github.com/NvChad/nvim-colorizer.lua',
  data = {
    events = {
      'BufNew',
      'BufRead',
      'BufWritePost',
      'TextChanged',
      'TextChangedI',
      'StdinReadPre',
    },
    postload = function()
      require('colorizer').setup({
        user_default_options = {
          names = false,
          rgb_fn = true,
          hsl_fn = true,
        },
      })
    end,
  },
}
