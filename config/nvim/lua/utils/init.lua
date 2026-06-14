---@diagnostic disable: assign-type-mismatch

return setmetatable({
  buf = nil, ---@module 'utils.buf'
  cmd = nil, ---@module 'utils.cmd'
  dap = nil, ---@module 'utils.dap'
  fs = nil, ---@module 'utils.fs'
  git = nil, ---@module 'utils.git'
  hl = nil, ---@module 'utils.hl'
  json = nil, ---@module 'utils.json'
  key = nil, ---@module 'utils.key'
  keys = nil, ---@module 'utils.keys'
  load = nil, ---@module 'utils.load'
  lsp = nil, ---@module 'utils.lsp'
  lua = nil, ---@module 'utils.lua'
  opt = nil, ---@module 'utils.opt'
  opts = nil, ---@module 'utils.opts'
  pack = nil, ---@module 'utils.pack'
  snippets = nil, ---@module 'utils.snip'
  static = nil, ---@module 'utils.static'
  stl = nil, ---@module 'utils.stl'
  str = nil, ---@module 'utils.str'
  syn = nil, ---@module 'utils.syn'
  tab = nil, ---@module 'utils.tab'
  term = nil, ---@module 'utils.term'
  term_t = nil, ---@module 'utils.term_t'
  test = nil, ---@module 'utils.test'
  ts = nil, ---@module 'utils.ts'
  web = nil, ---@module 'utils.web'
  win = nil, ---@module 'utils.win'
}, {
  __index = function(_, key)
    return require('utils.' .. key)
  end,
})
