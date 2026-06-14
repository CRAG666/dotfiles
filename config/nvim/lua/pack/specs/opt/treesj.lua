---@type pack.spec
return {
  src = 'https://github.com/Wansmer/treesj',
  data = {
    cmds = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
    keys = {
      -- stylua: ignore start
      { lhs = 'gsk',        opts = { desc = 'Join current treesitter node' } },
      { lhs = 'gs<Up>',     opts = { desc = 'Join current treesitter node' } },
      { lhs = 'gsj',        opts = { desc = 'Split current treesitter node' } },
      { lhs = 'gs<Down>',   opts = { desc = 'Split current treesitter node' } },
      { lhs = 'gsJ',        opts = { desc = 'Split current treesitter node recursively' } },
      { lhs = 'gs<S-Down>', opts = { desc = 'Split current treesitter node recursively' } },
      -- stylua: ignore end
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
      vim.keymap.set('n', 'gsk',        tsj.join,            { desc = 'Join current treesitter node' })
      vim.keymap.set('n', 'gs<Up>',     tsj.join,            { desc = 'Join current treesitter node' })
      vim.keymap.set('n', 'gsj',        tsj.split,           { desc = 'Split current treesitter node' })
      vim.keymap.set('n', 'gs<Down>',   tsj.split,           { desc = 'Split current treesitter node' })
      vim.keymap.set('n', 'gsJ',        tsj_split_recursive, { desc = 'Split current treesitter node recursively' })
      vim.keymap.set('n', 'gs<S-Down>', tsj_split_recursive, { desc = 'Split current treesitter node recursively' })
      -- stylua: ignore end
    end,
  },
}
