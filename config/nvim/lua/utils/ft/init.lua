return setmetatable({}, {
  __index = function(_, key)
    return require('utils.ft.' .. key)
  end,
})
