---@type pack.spec
return {
  src = 'https://github.com/kndndrj/nvim-dbee',
  data = {
    deps = {
      {
        src = 'https://github.com/MunifTanjim/nui.nvim',
        data = { optional = true },
      },
    },
    keys = {
      mode = 'n',
      lhs = '<leader>md',
      opts = { desc = 'Database Mode' },
    },
    -- build = function()
    --   require('dbee').install()
    -- end,
    postload = function()
      require('dbee').setup({})
      vim.keymap.set('n', '<leader>md', function()
        require('dbee').toggle()
      end)
    end,
  },
}
