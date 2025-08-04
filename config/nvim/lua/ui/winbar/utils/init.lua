return setmetatable({
  bar = nil, ---@module 'ui.winbar.utils.bar'
  menu = nil, ---@module 'ui.winbar.utils.menu'
  source = nil, ---@module 'ui.winbar.utils.source'
}, {
  __index = function(_, key)
    return vim.F.npcall(require, 'ui.winbar.utils.' .. key)
      or require('utils.' .. key)
  end,
})
