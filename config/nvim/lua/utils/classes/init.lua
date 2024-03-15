return setmetatable({}, {
  __index = function(self, key)
    self[key] = require('utils.classes.' .. key)
    return self[key]
  end,
})
