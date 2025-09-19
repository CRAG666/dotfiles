return {
  src = 'https://github.com/flwyd/vim-conjoin',
  data = {
    keys = {
      {
        lhs = 'J',
        mode = { 'n', 'x' },
        opts = { desc = 'Join lines' },
      },
      {
        lhs = 'gJ',
        mode = { 'n', 'x' },
        opts = { desc = 'Join lines without inserting/removing spaces' },
      },
    },
  },
}
