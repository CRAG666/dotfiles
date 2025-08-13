local key = require('utils.keymap')
local current = 2

vim.pack.add({ { src = 'https://github.com/CRAG666/betterTerm.nvim'} })

require('betterTerm').setup({
  -- position = 'vertical',
  -- size = 60,
  position = 'bot',
  size = 25,
  jump_tab_mapping = '<A-$tab>',
  new_tab_icon = require('utils.static.icons').git.Added,
})

key.map({ 'n', 't' }, '<C-;>', function()
  require('betterTerm').open()
end, { desc = 'Open terminal' })

key.map({ 'n', 't' }, '<C-/>', function()
  require('betterTerm').open(1)
end, { desc = 'Open terminal' })

key.map('n', '<leader>tt', function()
  require('betterTerm').select()
end, { desc = 'Select terminal' })

key.map('n', '<leader>ti', function()
  require('betterTerm').open(current)
  current = current + 1
end, { desc = 'Init new terminal' })
