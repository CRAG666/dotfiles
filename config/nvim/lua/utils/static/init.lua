return setmetatable({
  borders = nil, ---@module 'utils.static.borders'
  boxes = nil, ---@module 'utils.static.boxes'
  icons = nil, ---@module 'utils.static.icons'
}, {
  __index = function(_, key)
    return require('utils.static.' .. key)
  end,
})
