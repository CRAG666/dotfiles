return {
  src = 'https://github.com/folke/ts-comments.nvim',
  data = {
    events = { event = 'FileType' },
    postload = function()
      require('ts-comments').setup({})
    end,
  },
}