return setmetatable({
  bar = nil, ---@module 'plugin.winbar.utils.bar'
  menu = nil, ---@module 'plugin.winbar.utils.menu'
  source = nil, ---@module 'plugin.winbar.utils.source'
}, {
  __index = function(_, key)
    return vim.F.npcall(require, 'plugin.winbar.utils.' .. key)
      or require('utils.' .. key)
  end,
})
