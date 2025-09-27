return {
  src = 'https://github.com/rachartier/tiny-code-action.nvim',
  data = {
    events = { event = 'LspAttach' },
    postload = function()
      require('tiny-code-action').setup({ picker = 'snacks' })
      vim.keymap.set('n', '<C-.>', function()
        require('tiny-code-action').code_action()
      end, { desc = 'Code Action' })
    end,
  },
}

