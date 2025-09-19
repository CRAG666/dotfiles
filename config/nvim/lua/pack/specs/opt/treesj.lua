return {
  src = 'https://github.com/Wansmer/treesj',
  data = {
    cmds = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
    keys = {
      { lhs = '<M-C-K>', opts = { desc = 'Join current treesitter node' } },
      { lhs = '<M-C-Up>', opts = { desc = 'Join current treesitter node' } },
      { lhs = '<M-NL>', opts = { desc = 'Split current treesitter node' } },
      {
        lhs = '<M-C-Down>',
        opts = { desc = 'Split current treesitter node' },
      },
      {
        lhs = 'g<M-NL>',
        opts = { desc = 'Split current treesitter node recursively' },
      },
      {
        lhs = 'g<M-C-Down>',
        opts = { desc = 'Split current treesitter node recursively' },
      },
    },
    postload = function()
      local tsj = require('treesj')

      tsj.setup({
        use_default_keymaps = false,
        max_join_length = 1024,
      })

      ---@param preset table?
      ---@return nil
      function _G.tsj_split_recursive(_, preset)
        require('treesj.format')._format(
          'split',
          vim.tbl_deep_extend('force', preset or {}, {
            split = { recursive = true },
          })
        )
      end

      ---@param preset table?
      ---@return nil
      function _G.tsj_toggle_recursive(_, preset)
        require('treesj.format')._format(
          nil,
          vim.tbl_deep_extend('force', preset or {}, {
            split = { recursive = true },
            join = { recursive = true },
          })
        )
      end

      ---Split current treesitter node recursively
      local function tsj_split_recursive()
        vim.opt.operatorfunc = 'v:lua.tsj_split_recursive'
        vim.api.nvim_feedkeys('g@l', 'nx', true)
      end

      -- stylua: ignore start
      vim.keymap.set('n', '<M-C-K>',     tsj.join,            { desc = 'Join current treesitter node' })
      vim.keymap.set('n', '<M-C-Up>',    tsj.join,            { desc = 'Join current treesitter node' })
      vim.keymap.set('n', '<M-NL>',      tsj.split,           { desc = 'Split current treesitter node' })
      vim.keymap.set('n', '<M-C-Down>',  tsj.split,           { desc = 'Split current treesitter node' })
      vim.keymap.set('n', 'g<M-NL>',     tsj_split_recursive, { desc = 'Split current treesitter node recursively' })
      vim.keymap.set('n', 'g<M-C-Down>', tsj_split_recursive, { desc = 'Split current treesitter node recursively' })
      -- stylua: ignore end
    end,
  },
}
