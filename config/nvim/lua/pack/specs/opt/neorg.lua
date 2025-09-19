return {
  src = 'https://github.com/nvim-neorg/neorg',
  data = {
    deps = {
      { src = 'https://github.com/nvim-neorg/lua-utils.nvim' },
      { src = 'https://github.com/pysan3/pathlib.nvim' },
      { src = 'https://github.com/3rd/image.nvim' },
      { src = 'https://github.com/juniorsundar/neorg-extras' },
      { src = 'https://github.com/nvim-neotest/nvim-nio' },
    },
    keys = {
      { mode = 'n', lhs = '<leader>oo' },
      { mode = 'n', lhs = '<leader>oc' },
      { mode = 'n', lhs = '<leader>ot' },
    },
    cmds = { 'Neorg' },
    ft = { 'norg' },
    postload = function()
      require('neorg').setup({
        load = {
          ['core.defaults'] = {},
          ['core.keybinds'] = {},
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
                notes = '~/Documentos/Org/Notes',
                state_art = '~/Documentos/Org/Estado_Arte/',
              },
            },
          },
          ['core.looking-glass'] = {},
          ['core.export'] = {},
          ['core.summary'] = {},
          ['core.ui.calendar'] = {},
          ['core.latex.renderer'] = {},
          ['external.many-mans'] = {
            config = {
              metadata_fold = true,
              code_fold = true,
            },
          },
          ['external.agenda'] = {},
        },
      })

      vim.keymap.set('n', '<leader>oo', '<cmd>Neorg workspace notes<cr>', { desc = 'Toggle org notes' })
      vim.keymap.set('n', '<leader>oc', '<cmd>Neorg toggle-concealer<cr>', { desc = 'Toggle highlighting org' })
      vim.keymap.set('n', '<leader>ot', function()
        vim.cmd('Neorg toc')
        vim.cmd('vert resize 60')
      end, { desc = 'Toggle highlighting org' })

      local function open_workspace(w)
        vim.schedule(function()
          vim.cmd('Neorg workspace ' .. w)
        end)
      end

      local org_workspace = os.getenv('ORG_WORKSPACE')
      if org_workspace then
        open_workspace(org_workspace)
      end
    end,
  },
}