local current = 2
return {
  'CRAG666/betterTerm.nvim',
  dev = true,
  keys = {
    {
      mode = { 'n', 't' },
      '<C-;>',
      function()
        require('betterTerm').open()
      end,
      desc = 'Open terminal',
    },
    {
      mode = { 'n', 't' },
      '<C-/>',
      function()
        require('betterTerm').open(2)
      end,
      desc = 'Open terminal',
    },
    {
      '<leader>tt',
      function()
        require('betterTerm').select()
      end,
      desc = 'Select terminal',
    },
    {
      '<leader>ti',
      function()
        require('betterTerm').open(current)
        current = current + 1
      end,
      desc = 'Init new terminal',
    },
  },
  opts = {
    position = 'bot',
    size = 20,
    jump_tab_mapping = "<A-$tab>"
  },
}
