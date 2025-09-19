return {
  src = 'https://github.com/rasulomaroff/reactive.nvim',
  data = {
    events = { 'CursorMoved' },
    postload = function()
      require('reactive').setup({
        builtin = {
          cursorline = true,
          cursor = true,
          modemsg = true,
        },
        load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
      })
    end,
  },
}