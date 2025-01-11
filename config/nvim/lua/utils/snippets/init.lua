return setmetatable({}, {
  __index = function(_, key)
    return require('utils.snippets.' .. key)
  end,
})
