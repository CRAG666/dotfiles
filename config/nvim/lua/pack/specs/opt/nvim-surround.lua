---@type pack.spec
return {
  src = 'https://github.com/kylechui/nvim-surround',
  data = {
    keys = {
      { lhs = 'ys', opts = { desc = 'Surround' } },
      { lhs = 'yss', opts = { desc = 'Surround line' } },
      { lhs = 'yS', opts = { desc = 'Surround in new lines' } },
      { lhs = 'ySS', opts = { desc = 'Surround line in new lines' } },
      { lhs = 'ds', opts = { desc = 'Delete surrounding' } },
      { lhs = 'cs', opts = { desc = 'Change surrounding' } },
      { lhs = 'S', mode = 'x', opts = { desc = 'Surround' } },
      { lhs = 'gS', mode = 'x', opts = { desc = 'Surround in new lines' } },
      { lhs = '<C-g>s', mode = 'i', opts = { desc = 'Surround' } },
      { lhs = '<C-g>S', mode = 'i', opts = { desc = 'Surround' } },
    },
    postload = function()
      require('nvim-surround').setup({
        surrounds = {
          -- Bold markers in markdown
          ['<M-*>'] = {
            add = { '**', '**' },
          },
        },
      })
    end,
  },
}
