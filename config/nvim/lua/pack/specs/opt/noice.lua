return {
  src = 'https://github.com/folke/noice.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/MunifTanjim/nui.nvim',
        data = { optional = false },
      },
    },
    events = { 'VimEnter' },
    postload = function()
      require('noice').setup({
        lsp = {
          progress = {
            enabled = false,
          },
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
              },
            },
            view = 'mini',
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
        },
      })
    end,
  },
}
