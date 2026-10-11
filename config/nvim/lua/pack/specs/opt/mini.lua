return {
  src = 'https://github.com/nvim-mini/mini.nvim',
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
      require('mini.ai').setup({
        -- Keep nvim's builtin `an`/`in` (treesitter incremental selection)
        -- and `al`/`il` (all lines / inner line) text objects
        mappings = {
          around_next = '',
          inside_next = '',
          around_last = '',
          inside_last = '',
        },
      })
    end,
  },
}
