return {
  src = 'supermaven-inc/supermaven-nvim',
  events = { 'InsertEnter' },
  keys = {
    { mode = 'i', lhs = '<C-J>', opts = { desc = 'accept word' } },
    { mode = 'i', lhs = '<C-I>', opts = { desc = 'accept suggestion' } },
  },
  postload = function()
    require('supermaven-nvim').setup({
      keymaps = {
        accept_suggestion = '<C-I>',
        clear_suggestion = '<C-CR>',
        accept_word = '<C-J>',
      },
      ignore_filetypes = { 'bigfile' },
    })
  end,
}
