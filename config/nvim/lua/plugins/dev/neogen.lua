local key = require('utils.keymap')
vim.pack.add({ { src = 'https://github.com/danymat/neogen' } })

local function setup()
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
end

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

key.maps_lazy('neogen', setup, 'n', '<leader>n', maps)
