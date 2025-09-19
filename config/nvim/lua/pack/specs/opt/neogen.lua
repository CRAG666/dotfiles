return {
  src = 'https://github.com/danymat/neogen',
  data = {
    cmds = { 'Neogen' },
    keys = {
      { mode = 'n', lhs = '<leader>nc' },
      { mode = 'n', lhs = '<leader>nf' },
      { mode = 'n', lhs = '<leader>ni' },
      { mode = 'n', lhs = '<leader>nt' },
    },
    postload = function()
      require('neogen').setup({
        enabled = true,
        languages = {
          lua = {
            template = {
              annotation_convention = 'emmylua',
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

      local key = require('utils.keymap')
      local maps = {
        {
          'c',
          function()
            require('neogen').generate({ type = 'class' })
          end,
          'Comment [c]lass',
        },
        {
          'f',
          function()
            require('neogen').generate({ type = 'func' })
          end,
          'Comment [f]unction',
        },
        {
          'i',
          function()
            require('neogen').generate({ type = 'file' })
          end,
          'Comment F[i]le',
        },
        {
          't',
          function()
            require('neogen').generate({ type = 'type' })
          end,
          'Comment [t]ype',
        },
      }

      key.maps('n', '<leader>n', maps)
    end,
  },
}
