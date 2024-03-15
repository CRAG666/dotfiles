local utils = require('utils')

return setmetatable({}, {
  __index = function(self, key)
    local has_local_util, local_util =
      pcall(require, 'ui.winbar.utils.' .. key)
    self[key] = has_local_util and local_util or utils[key]
    return self[key]
  end,
})
