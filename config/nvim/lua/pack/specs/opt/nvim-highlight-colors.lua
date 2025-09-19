return {
  src = 'https://github.com/brenoprata10/nvim-highlight-colors',
  data = {
    events = {'FileType',},
    postload = function()
  require('nvim-highlight-colors').setup({
    render = 'background',
    enable_tailwind = false,
  })
    end,
  },
}
