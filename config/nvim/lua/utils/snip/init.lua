---@diagnostic disable: assign-type-mismatch

return setmetatable({
  conds = nil, ---@module 'utils.snip.conds'
  funcs = nil, ---@module 'utils.snip.funcs'
  nodes = nil, ---@module 'utils.snip.nodes'
  snips = nil, ---@module 'utils.snip.snips'
}, {
  __index = function(_, key)
    return require('utils.snip.' .. key)
  end,
})
