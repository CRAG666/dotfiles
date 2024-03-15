return setmetatable({}, {
  __index = function(self, key)
    self[key] = require('utils.ft.' .. key)
    return self[key]
  end,
})
