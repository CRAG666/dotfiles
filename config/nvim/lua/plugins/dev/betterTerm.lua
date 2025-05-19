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
        require('betterTerm').open(1)
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
    -- position = 'vertical',
    -- size = 60,
    position = 'bot',
    size = 25,
    jump_tab_mapping = "<A-$tab>",
    new_tab_icon = require('utils.static.icons').git.Added
  },
}
