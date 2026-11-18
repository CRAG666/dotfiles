---@type pack.spec
return {
  src = 'https://github.com/tronikelis/ts-autotag.nvim',
  data = {
    events = 'InsertEnter',
    idle = true,
    postload = function()
      require('ts-autotag').setup()
    end,
  },
}
