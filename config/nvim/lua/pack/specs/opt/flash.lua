return {
  src = 'https://github.com/folke/flash.nvim',
  data = {
    keys = {
      { mode = { 'n', 'x', 'o' }, lhs = 's', opts = { desc = 'Flash' }},
      -- { mode = { 'n', 'x', 'o' }, lhs = 'S' },
      -- { mode = 'o', lhs = 'r' },
      -- { mode = { 'o', 'x' }, lhs = 'R' },
      -- { mode = 'c', lhs = '<c-s>' },
    },
    postload = function()
      require('flash').setup({})
      vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
        require('flash').jump()
      end, { desc = 'Flash' })
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
        require('flash').treesitter()
      end, { desc = 'Flash Treesitter' })
      vim.keymap.set('o', 'r', function()
        require('flash').remote()
      end, { desc = 'Remote Flash' })
      vim.keymap.set({ 'o', 'x' }, 'R', function()
        require('flash').treesitter_search()
      end, { desc = 'Treesitter Search' })
      vim.keymap.set('c', '<c-s>', function()
        require('flash').toggle()
      end, { desc = 'Toggle Flash Search' })
    end,
  },
}
