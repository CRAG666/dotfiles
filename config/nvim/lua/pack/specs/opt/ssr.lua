return {
  src = 'https://github.com/cshuaimin/ssr.nvim',
  data = {
    keys = {
      {
        mode = { 'n', 'x' },
        lhs = '<leader>rs',
        opts = {{ desc = 'Search [r]eplace [s]tructure' }}
      },
    },
    postload = function()
      require('ssr').setup({
        border = 'rounded',
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        adjust_window = true,
        keymaps = {
          close = 'q',
          next_match = 'n',
          prev_match = 'N',
          replace_confirm = '<cr>',
          replace_all = '<leader><cr>',
        },
      })
      vim.keymap.set({ 'n', 'x' }, '<leader>rs', function()
        require('ssr').open()
      end)
    end,
  },
}
