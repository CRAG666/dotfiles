return setmetatable({}, {
  __index = function(_, key)
    return require('utils.static.' .. key)
  end,
})
