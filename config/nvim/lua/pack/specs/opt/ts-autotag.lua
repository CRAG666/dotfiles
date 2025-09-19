return {
  src = 'https://github.com/tronikelis/ts-autotag.nvim',
  data = {
    events = 'InsertEnter',
    postload = function()
      require('ts-autotag').setup()
    end,
  },
}
