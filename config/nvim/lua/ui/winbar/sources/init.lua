---@class winbar_source_t
---@field get_symbols fun(buf: integer, win: integer, cursor: integer[]): winbar_symbol_t[]

---@type table<string, winbar_source_t>
return setmetatable({}, {
  __index = function(self, key)
    local source = require('ui.winbar.sources.' .. key)
    self[key] = source
    return source
  end,
})
