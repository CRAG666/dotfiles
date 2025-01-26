return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(
          opts.ensure_installed,
          { 'markdown', 'markdown_inline' }
        )
      end
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'markdownlint', 'marksman' })
    end,
  },
  {
    'nvimtools/none-ls.nvim',
    optional = true,
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.markdownlint,
      })
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    ft = {
      'md',
      'markdown',
      'norg',
      'rmd',
      'org',
      'vimwiki',
      'typst',
      'tex',
      'quarto',
      'Avante',
      'codecompanion',
    },
    opts = {
      preview = {
        enable = true,
        filetypes = {
          'md',
          'markdown',
          'norg',
          'rmd',
          'org',
          'vimwiki',
          'typst',
          'latex',
          'quarto',
          'Avante',
          'codecompanion',
        },
      },
      latex = {
        enable = true,
        blocks = {
          enable = true,
          conceal = true,
          markers = { '$$', '\\[', '\\begin{equation}' },
          preview = true,
        },
        inlines = true,
        commands = true,
      },
    },
    config = function(_, opts)
      require('markview.extras.checkboxes').setup()
      require('markview').setup(opts)
    end,
  },
}
