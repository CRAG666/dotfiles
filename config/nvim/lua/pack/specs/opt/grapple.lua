return {
  src = 'https://github.com/cbochs/grapple.nvim',
  data = {
    keys = {
      { mode = 'n', lhs = '<leader>m', rhs = '<cmd>Grapple toggle<cr>', opts = { desc = '[m]ark file' } },
      { mode = 'n', lhs = "<leader>'", rhs = '<cmd>Grapple toggle_tags<cr>', opts = { desc = 'Marked Files' } },
      { mode = 'n', lhs = '<leader>`', rhs = '<cmd>Grapple toggle_scopes<cr>', opts = { desc = 'Grapple toggle scopes' } },
      { mode = 'n', lhs = '<leader>j', rhs = '<cmd>Grapple cycle forward<cr>', opts = { desc = 'Grapple cycle forward' } },
      { mode = 'n', lhs = '<leader>k', rhs = '<cmd>Grapple cycle backward<cr>', opts = { desc = 'Grapple cycle backward' } },
    },
    cmds = { 'Grapple' },
  },
}
