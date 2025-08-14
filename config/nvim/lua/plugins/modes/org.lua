local key = require('utils.keymap')

local function setup()
  vim.pack.add({
    { src = 'https://github.com/nvim-neorg/lua-utils.nvim' },
    { src = 'https://github.com/pysan3/pathlib.nvim' },
    { src = 'https://github.com/3rd/image.nvim' },
    { src = 'https://github.com/nvim-neorg/neorg' },
    { src = 'https://github.com/juniorsundar/neorg-extras' },
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
