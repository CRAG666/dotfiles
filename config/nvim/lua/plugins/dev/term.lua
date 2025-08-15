local key = require('utils.keymap')
local current = 2

local function setup()
  vim.opt.runtimepath:prepend(vim.fn.expand('~/Git/betterTerm.nvim'))
  require('betterTerm').setup({
    position = 'vert',
    size = math.floor(vim.o.columns / 2),
    jump_tab_mapping = '<A-$tab>',
    new_tab_icon = require('utils.static.icons').git.Added,
  })
end

local open = {
  {
    ';>',
    function()
      require('betterTerm').open()
    end,
    'Open terminal 0',
  },
  {
    '/>',
    function()
      require('betterTerm').open(1)
    end,
    'Open terminal 1',
  },
}

key.maps_lazy('betterTerm', setup, { 'n', 't' }, '<C-', open)

local more = {
  {
    't',
    function()
      require('betterTerm').select()
    end,
    'Select terminal',
  },
  {
    'i',
    function()
      require('betterTerm').open(current)
      current = current + 1
    end,
    'Create new terminal',
  },
  {
    'r',
    function()
      require('betterTerm').rename()
    end,
    'Rename terminal',
  },
}

key.maps_lazy('betterTerm', setup, 'n', '<leader>t', more)
