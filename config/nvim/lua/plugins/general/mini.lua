local fn = require('utils.fn')
fn.lazy_load('CursorMoved', 'mini', function()
  vim.pack.add({ { src = 'https://github.com/echasnovski/mini.move' } })
  vim.pack.add({ { src = 'https://github.com/echasnovski/mini.splitjoin' } })
  vim.pack.add({ { src = 'https://github.com/echasnovski/mini.ai' } })

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
end)

