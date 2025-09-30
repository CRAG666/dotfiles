return {
  src = 'https://github.com/dimtion/guttermarks.nvim',
  data = {
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    postload = function()
      require('guttermarks').setup({
        global_mark = { enabled = true },
        special_mark = { enabled = true },
      })
    end,
  },
}
