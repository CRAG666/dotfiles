-- Port of nvim's `core/autocmds.lua`

local util = require('core.util')

local bigfile_max_size = 1048576

-- Disable syntax highlighting in big files
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  if win.file.size > bigfile_max_size then
    win.bigfile = true
    win:set_syntax(nil)
  end
end)

-- Remove trailing whitespace before saving (`%s/\s\+$//e`)
vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(file)
  if file.size > bigfile_max_size then
    return
  end
  -- Replacing lines invalidates cursors on them, restore them afterwards
  local cursors = {}
  for win in vis:windows() do
    if win.file == file then
      local sel = win.selection
      table.insert(cursors, { sel = sel, line = sel.line, col = sel.col })
    end
  end

  local lines = file.lines
  for i = 1, #lines do
    local line = lines[i]
    if line:find('%s$') then
      lines[i] = line:gsub('%s+$', '')
    end
  end

  for _, c in ipairs(cursors) do
    local len = #(lines[c.line] or '')
    c.sel:to(c.line, math.max(1, math.min(c.col, len)))
  end
end)

-- Keep a copy of the previous version of each saved file (`backup = true`,
-- `backupdir` without '.'), named like nvim's: full path with '%' separators
local backup_dir = (
  os.getenv('XDG_STATE_HOME') or os.getenv('HOME') .. '/.local/state'
) .. '/vis/backup'

vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(file, path)
  if not path or not util.exists(path) or file.size > bigfile_max_size then
    return
  end
  local name = path:gsub('/', '%%')
  os.execute(
    string.format(
      'mkdir -p %s && cp -p %s %s 2>/dev/null',
      util.shellescape(backup_dir),
      util.shellescape(path),
      util.shellescape(backup_dir .. '/' .. name .. '~')
    )
  )
end)
