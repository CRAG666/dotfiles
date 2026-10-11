return setmetatable({
  bar = nil, ---@module 'plugin.winbar.utils.bar'
  menu = nil, ---@module 'plugin.winbar.utils.menu'
  source = nil, ---@module 'plugin.winbar.utils.source'
}, {
  __index = function(self, key)
    -- Cache the module, a failed `require()` searches the runtimepath again
    -- on every access
    local mod = vim.npcall(require, 'plugin.winbar.utils.' .. key)
      or require('utils.' .. key)
    rawset(self, key, mod)
    return mod
  end,
})
