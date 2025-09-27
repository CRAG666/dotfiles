return {
  src = 'https://github.com/chentoast/marks.nvim',
  data = {
    events = { 'VimEnter' },
    postload = function()
      require('marks').setup({})
    end,
  },
}

