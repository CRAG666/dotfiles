return {
  src = 'https://github.com/akinsho/git-conflict.nvim',
  data = {
    events = 'BufReadPre',
    postload = function()
      ---@diagnostic disable-next-line: missing-fields
      require('git-conflict').setup({
        disable_diagnostics = true,
        default_mappings = {
          ours = 'c<',
          theirs = 'c>',
          none = 'c-',
          both = 'c=',
          next = ']x',
          prev = '[x',
        },
      })

      -- Git conflict by default only use background color of `hl-DiffText` or
      -- `hl-DiffAdd` for conflict text. This does not play well with colorschemes
      -- using intense bg color and reversed fg color for diff text.
      require('utils.hl').persist(function()
        vim.api.nvim_set_hl(0, 'GitConflictCurrent', { link = 'DiffText' })
        vim.api.nvim_set_hl(0, 'GitConflictIncoming', { link = 'DiffAdd' })
        vim.api.nvim_set_hl(0, 'GitConflictAncestor', { link = 'DiffText' })
      end)
    end,
  },
}

