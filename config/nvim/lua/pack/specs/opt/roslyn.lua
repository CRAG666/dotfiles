return {
  src = 'https://github.com/seblyng/roslyn.nvim',
  data = {
    events = { event = 'FileType', pattern = 'cs' },
    postload = function()
      require('roslyn').setup()
    end,
  },
}
