local key = require('utils.keymap')
local prefix = '<leader>n'

vim.pack.add({ { src = 'https://github.com/danymat/neogen' } })
vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter' } })

require('neogen').setup({
  enabled = true,
  languages = {
    lua = {
      template = {
        annotation_convention = 'emmylua', -- for a full list of annotation_conventions, see supported-languages below,
      },
    },
    cs = {
      template = {
        annotation_convention = 'xmldoc',
      },
    },
    python = {
      template = {
        annotation_convention = 'google_docstrings',
      },
    },
    typescript = {
      template = {
        annotation_convention = 'jsdoc',
      },
    },
  },
})

key.map('n', prefix .. 'c', function()
  require('neogen').generate({ type = 'class' })
end, { desc = 'Comment [c]lass' })

key.map('n', prefix .. 'f', function()
  require('neogen').generate({ type = 'func' })
end, { desc = 'Comment [f]unction' })

key.map('n', prefix .. 'i', function()
  require('neogen').generate({ type = 'file' })
end, { desc = 'Comment F[i]le' })

key.map('n', prefix .. 't', function()
  require('neogen').generate({ type = 'type' })
end, { desc = 'Comment [t]ype' })