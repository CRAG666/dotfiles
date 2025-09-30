return {
  src = 'supermaven-inc/supermaven-nvim',
  data = {
    events = { 'InsertEnter' },
    keys = {
      { mode = 'i', lhs = '<C-,>', opts = { desc = 'accept word' } },
      { mode = 'i', lhs = '<C-.>', opts = { desc = 'accept suggestion' } },
    },
    postload = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<C-.>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-,>',
        },
      })
    end,
  },
}
