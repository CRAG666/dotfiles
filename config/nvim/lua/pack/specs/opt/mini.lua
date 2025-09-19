return {
  src = 'https://github.com/echasnovski/mini.nvim',
  data = {
    events = { 'CursorMoved' },
    postload = function()
      require('mini.move').setup({
        mappings = {
          left = '<A-h>',
          right = '<A-l>',
          down = '<A-j>',
          up = '<A-k>',
          line_left = '<A-h>',
          line_right = '<A-l>',
          line_down = '<A-j>',
          line_up = '<A-k>',
        },
      })
      require('mini.splitjoin').setup({})
      require('mini.ai').setup({})
    end,
  },
}
