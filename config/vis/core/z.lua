-- Port of nvim's `plugin/z.lua` on top of zoxide: project roots of opened
-- files are recorded (nvim records them through `auto_cwd`) and directories
-- open in the file explorer

local util = require('core.util')
local sh = util.shellescape

---@param args string[]
---@return string
local function query_args(args)
  local quoted = {}
  for _, arg in ipairs(args) do
    table.insert(quoted, sh(arg))
  end
  return table.concat(quoted, ' ')
end

---@param args string[]
local function select(args)
  local out = util.run('zoxide query -l ' .. query_args(args))
  local dirs = {}
  for dir in (out or ''):gmatch('[^\n]+') do
    table.insert(dirs, dir)
  end
  if #dirs == 0 then
    vis:info('No z directory matches')
    return
  end
  local dir = require('core.pick').select(dirs, 'Open directory')
  if dir then
    require('core.pick').explore(dir)
  end
end

vis:command_register('Z', function(argv)
  local dir = util.run('zoxide query ' .. query_args(argv))
  if not dir then
    vis:info('No z directory matches')
    return false
  end
  require('core.pick').explore(dir)
  return true
end, 'Open a directory from z')

vis:command_register('ZSelect', function(argv)
  select(argv)
  return true
end, 'Open a directory from z interactively')

vis:map(vis.modes.NORMAL, ' z', function()
  select({})
end, 'Open a directory from z')

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  if not win.file.path then
    return
  end
  local dir = util.file_dir(win)
  os.execute(
    string.format(
      'zoxide add %s >/dev/null 2>&1 &',
      sh(util.root(dir, util.root_markers) or dir)
    )
  )
end)
