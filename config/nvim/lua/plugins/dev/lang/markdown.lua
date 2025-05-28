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
      vim.list_extend(opts.ensure_installed, { 'marksman' })
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    ft = {
      'markdown',
      'codecompanion',
      'norg',
      'vimwiki',
      'typst',
      'tex',
      'quarto',
    },
    opts = {
      preview = {
        filetypes = {
          'markdown',
          'codecompanion',
          'norg',
          'vimwiki',
          'typst',
          'latex',
          'quarto',
        },
        ignore_buftypes = {},
        condition = function(buffer)
          local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt

          if bt == 'nofile' and ft == 'codecompanion' then
            return true
          elseif bt == 'nofile' then
            return false
          else
            return true
          end
        end,
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
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   opts = {
  --     file_types = { "markdown", "Avante" },
  --   },
  --   ft = { "markdown", "Avante" },
  -- },
}
