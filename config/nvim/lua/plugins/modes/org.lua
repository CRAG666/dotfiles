local key = require('utils.keymap')

local function setup()
  vim.pack.add({
    'https://github.com/nvim-neorg/lua-utils.nvim',
    'https://github.com/pysan3/pathlib.nvim',
    'https://github.com/3rd/image.nvim',
    'https://github.com/nvim-neorg/neorg',
    'https://github.com/juniorsundar/neorg-extras',
    'https://github.com/nvim-neotest/nvim-nio',
  })

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
end

key.maps_lazy('neorg', setup, 'n', '<leader>o', {
  {
    'o',
    'Neorg workspace notes',
    'Toggle org notes',
  },
  {

    'c',
    'Neorg toggle-concealer',
    'Toggle highlighting org',
  },
  {
    't',
    function()
      vim.cmd('Neorg toc')
      vim.cmd('vert resize 60')
    end,
    'Toggle highlighting org',
  },
})

local function open_workspace(w)
  vim.schedule(function()
    setup()
    vim.cmd('Neorg workspace ' .. w)
  end)
end

local M = {}

function M.open_workspace()
  local org_workspace = os.getenv('ORG_WORKSPACE')
  if org_workspace then
    open_workspace(org_workspace)
  end
end

return M
