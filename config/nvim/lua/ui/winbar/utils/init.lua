return setmetatable({}, {
  __index = function(_, key)
    return vim.F.npcall(require, 'ui.winbar.utils.' .. key)
      or require('utils.' .. key)
  end,
})
