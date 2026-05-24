local key = require('utils.keymap')
local current = 2

local M = {}
local load = false

function M.setup()
  if not load then
    vim.opt.runtimepath:prepend(vim.fn.expand('~/Git/betterTerm.nvim'))
    require('betterTerm').setup({
      position = 'vert',
      size = math.floor(vim.o.columns / 2),
      jump_tab_mapping = '<A-$tab>',
      new_tab_icon = require('utils.static.icons').git.Added,
    })
    load = true
  end
end

local more = {
  {
    't',
    function()
      require('betterTerm').open()
    end,
    'Open terminal 0',
  },
  {
    'y',
    function()
      require('betterTerm').open(1)
    end,
    'Open terminal 1',
  },
  {
    's',
    function()
      require('betterTerm').select()
    end,
    'Select terminal',
  },
  {
    'n',
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

key.maps_lazy('betterTerm', M.setup, 'n', '<leader>t', more)

return M
