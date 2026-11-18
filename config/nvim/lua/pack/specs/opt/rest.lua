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
      lhs = '<leader>mr',
      opts = { desc = '[R]un method' },
    },
    cmds = { 'Rest' },
    events = {
      event = 'FileType',
      pattern = 'http',
      retrig = true,
    },
    postload = function()
      vim.keymap.set('n', '<leader>mr', ':Rest run<cr>')
    end,
  },
}
