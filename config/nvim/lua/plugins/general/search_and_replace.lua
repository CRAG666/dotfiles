local key = require('utils.keymap')

vim.pack.add({ { src = 'https://github.com/AckslD/muren.nvim' } })
vim.pack.add({ { src = 'https://github.com/cshuaimin/ssr.nvim' } })

require('muren').setup()
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

key.map('n', '<leader>rp', ':MurenToggle<CR>', { desc = 'Search [r]eplace [p]attern' })
key.map({ 'n', 'x' }, '<leader>rs', function()
  require('ssr').open()
end, { desc = 'Search [r]eplace [s]tructure' })