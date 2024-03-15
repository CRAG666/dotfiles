return setmetatable({}, {
  __index = function(self, key)
    self[key] = require("utils." .. key)
    return self[key]
  end,
})
