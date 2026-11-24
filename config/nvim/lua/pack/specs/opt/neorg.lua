return {
  src = 'https://github.com/nvim-neorg/neorg',
  data = {
    deps = {
      {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        data = { optional = false },
      },
      { src = 'https://github.com/nvim-neorg/lua-utils.nvim' },
      { src = 'https://github.com/pysan3/pathlib.nvim' },
      { src = 'https://github.com/3rd/image.nvim' },
      { src = 'https://github.com/nvim-neotest/nvim-nio' },
      { src = 'https://github.com/MunifTanjim/nui.nvim' },
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
      { src = 'https://github.com/folke/zen-mode.nvim' },
      -- { src = 'https://github.com/juniorsundar/neorg-extras' },
    },
    keys = {
      { mode = 'n', lhs = '<leader>oo', opts = { desc = 'Toggle org notes' } },
      {
        mode = 'n',
        lhs = '<leader>oc',
        opts = { desc = 'Toggle highlighting org' },
      },
      {
        mode = 'n',
        lhs = '<leader>ot',
        opts = { desc = 'Toggle toc org' },
      },
    },
    cmds = { 'Neorg' },
    events = {
      event = 'FileType',
      pattern = 'norg',
      retrig = true,
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        group = vim.api.nvim_create_augroup('neorg.parsers', {}),
        desc = 'Register the norg parsers, nvim-treesitter does not ship them.',
        callback = function()
          local parsers = require('nvim-treesitter.parsers')
          parsers.norg = {
            install_info = {
              url = 'https://github.com/nvim-neorg/tree-sitter-norg',
              -- nvim-neorg/tree-sitter-norg#82: scanner rewritten in C, `main`
              -- still has the C++ scanner that tree-sitter cannot build
              revision = '35e2a51fce194d064bc32233b6bffa89cf234580',
            },
          }
          parsers.norg_meta = {
            install_info = {
              url = 'https://github.com/nvim-neorg/tree-sitter-norg-meta',
              revision = '729d4e54fb881ba0ddf0f925ec78401354c7c6db',
            },
          }
        end,
      })
    end,
    postload = function()
      require('neorg').setup({
        load = {
          ['core.defaults'] = {},
          ['core.autocommands'] = {},
          ['core.integrations.treesitter'] = {},
          ['core.concealer'] = {
            config = {
              icon_preset = 'basic',
              icons = {
                code_block = {
                  conceal = true,
                },
                delimiter = {
                  horizontal_line = {
                    icon = '━',
                  },
                },
                definition = {
                  single = { icon = '🔖 ' },
                  multi_prefix = { icon = '󰉾 ' },
                  multi_suffix = { icon = '󰝗 ' },
                },
                list = {
                  icons = { '✿' },
                },
                quote = {
                  icons = { '󰇙' },
                },
                heading = {
                  icons = {
                    '🌸 ',
                    '🌼 ',
                    '🌺 ',
                    '💠 ',
                    '💮 ',
                    '🪷 ',
                  },
                },
              },
            },
          },
          ['core.dirman'] = {
            config = {
              workspaces = {
                life = '~/Documents/Org/Life/',
                work = '~/Documents/Org/Work/',
                phd = '~/Documents/Org/PhD/',
                lectures = '~/Documents/Projects/Postgraduate_studies/lectures',
              },
            },
          },
          ['core.export'] = {},
          ['core.latex.renderer'] = {},
          ['core.presenter'] = { config = { zen_mode = 'zen-mode' } },
          ['core.summary'] = {},
          ['core.text-objects'] = {},
          ['core.fs'] = {},
          ['core.ui'] = {},
          ['core.syntax'] = {},
          ['core.neorgcmd'] = {},
        },
      })

      vim.keymap.set('n', '<leader>oo', '<cmd>Neorg workspace life<cr>')
      vim.keymap.set('n', '<leader>oc', '<cmd>Neorg toggle-concealer<cr>')
      vim.keymap.set('n', '<leader>ot', function()
        vim.cmd('Neorg toc')
        vim.cmd('vert resize 60')
      end)
    end,
  },
}
