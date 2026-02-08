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
    },
    postload = function()
      require('neorg').setup({
        load = {
          ['core.defaults'] = {},
          ['core.keybinds'] = {},
          ['core.autocommands'] = {},
          ['core.highlights'] = {},
          ['core.integrations.treesitter'] = {},
          ['core.neorgcmd'] = {},
          ['core.concealer'] = {
            config = {
              dim_code_blocks = { conceal = false },
              icon_preset = 'basic',
              icons = {
                code_block = {
                  conceal = true,
                },
                delimiter = {
                  horizontal_line = {
                    icon = '■',
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
                    '🍀 ',
                    '🪻 ',
                  },
                },
              },
            },
          },
          ['core.dirman'] = {
            config = {
              workspaces = {
                life = '~/Documentos/Org/Life/',
                work = '~/Documentos/Org/Work/',
                master = '~/Documentos/Proyectos/Maestria/Notes/',
                phd = '~/Documentos/Proyectos/Doctorado/Notes/',
              },
            },
          },
          ['core.looking-glass'] = {},
          ['core.export'] = {},
          ['core.summary'] = {},
          ['core.ui.calendar'] = {},
          ['core.latex.renderer'] = {},
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
