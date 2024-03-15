return setmetatable({}, {
  __index = function(self, key)
    self[key] = require('utils.static.' .. key)
    return self[key]
  end,
})
