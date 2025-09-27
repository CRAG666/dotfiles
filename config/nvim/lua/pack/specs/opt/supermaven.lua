return {
  src = 'supermaven-inc/supermaven-nvim',
  events = { 'InsertEnter' },
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
