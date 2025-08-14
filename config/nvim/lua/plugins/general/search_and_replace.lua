local key = require('utils.keymap')

local function muren()
  vim.pack.add({ { src = 'https://github.com/AckslD/muren.nvim' } })
  require('muren').setup({})
end

local function ssr()
  vim.pack.add({ { src = 'https://github.com/cshuaimin/ssr.nvim' } })
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
end

key.map_lazy(
  'muren',
  muren,
  'n',
  '<leader>rp',
  'MurenToggle',
  { desc = 'Search [r]eplace [p]attern' }
)
key.map_lazy('ssr', ssr, { 'n', 'x' }, '<leader>rs', function()
  require('ssr').open()
end, { desc = 'Search [r]eplace [s]tructure' })
