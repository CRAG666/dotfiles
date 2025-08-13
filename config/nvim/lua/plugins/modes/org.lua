local key = require('utils.keymap')

vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter' } })
vim.pack.add({ { src = 'https://github.com/nvim-neorg/neorg' } })
vim.pack.add({ { src = 'https://github.com/juniorsundar/neorg-extras' } })

local neorg_leader = '<leader>o'
local neorg_enabled = false

require('neorg').setup({
  load = {
    ['core.defaults'] = {},
    ['core.keybinds'] = {},
    ['core.concealer'] = {
      config = {
        dim_code_blocks = { conceal = false },
        icon_preset = 'basic',
        -- icon_preset = "diamond",
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
    ['core.dirman'] = { -- Manages Neorg workspaces
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
        metadata_fold = true, -- If want @data property ... @end to fold
        code_fold = true, -- If want @code ... @end to fold
      },
    },
    -- OPTIONAL
    ['external.agenda'] = {},
  },
})

key.map('n', neorg_leader .. 'o', function()
  if neorg_enabled then
    vim.cmd.Neorg('return')
    neorg_enabled = false
    return
  end
  vim.cmd.Neorg.workspace('notes')
  neorg_enabled = true
end, { desc = 'Toggle org notes' })

key.map('n', neorg_leader .. 'c', function()
  vim.cmd.Neorg('toggle-concealer')
end, { desc = 'Toggle highlighting org' })

key.map('n', neorg_leader .. 'tt', function()
  vim.cmd.Neorg('toc')
  vim.cmd('vert resize 60')
end, { desc = 'Toggle highlighting org' })