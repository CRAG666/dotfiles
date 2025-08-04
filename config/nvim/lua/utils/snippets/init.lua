---@diagnostic disable: assign-type-mismatch

return setmetatable({
  conds = nil, ---@module 'utils.snippets.conds'
  funcs = nil, ---@module 'utils.snippets.funcs'
  nodes = nil, ---@module 'utils.snippets.nodes'
  snips = nil, ---@module 'utils.snippets.snips'
}, {
  __index = function(_, key)
    return require('utils.snippets.' .. key)
  end,
})
