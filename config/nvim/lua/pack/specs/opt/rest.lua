return {
  src = 'https://github.com/rest-nvim/rest.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        data = { optional = false },
      },
    },
    keys = {
      mode = 'n',
      lhs = '<leader>R',
      opts = { desc = '[R]un method' },
    },
    cmds = { 'Rest' },
    events = {
      event = 'FileType',
      pattern = 'http',
    },
    postload = function()
      vim.keymap.set('n', '<leader>R', ':Rest run<cr>')
    end,
  },
}
