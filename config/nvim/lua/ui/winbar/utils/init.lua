local utils = require('utils')

return setmetatable({}, {
  __index = function(_, key)
    local has_local_util, local_util =
      pcall(require, 'ui.winbar.utils.' .. key)
    return has_local_util and local_util or utils[key]
  end,
})
