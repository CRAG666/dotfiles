---@class winbar.source
---@field get_symbols fun(buf: integer, win: integer, cursor: integer[]): winbar.symbol[]

---@type table<string, winbar.source>
return setmetatable({}, {
  __index = function(_, key)
    return require('plugin.winbar.sources.' .. key)
  end,
})
