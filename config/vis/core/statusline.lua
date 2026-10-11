-- Port of nvim's `plugin/statusline.lua`: mode, file, git branch, filetype,
-- indentation and position; vis statuslines are plain text

local util = require('core.util')

local modes = {
  [vis.modes.NORMAL] = 'NORMAL',
  [vis.modes.OPERATOR_PENDING] = 'O-PENDING',
  [vis.modes.VISUAL] = 'VISUAL',
  [vis.modes.VISUAL_LINE] = 'V-LINE',
  [vis.modes.INSERT] = 'INSERT',
  [vis.modes.REPLACE] = 'REPLACE',
}

---Cache the git branch of the window's file, it doesn't change while editing
---@param win table
local function update_branch(win)
  local dir = util.file_dir(win)
  local branch = util.run(
    string.format('git -C %s branch --show-current', util.shellescape(dir))
  )
  win.git_branch = branch ~= '' and branch or nil
end

vis.events.subscribe(vis.events.WIN_OPEN, update_branch)

-- Nerd font glyphs only where nvim would use them (`vim.g.has_nf`)
local branch_icon = (os.getenv('TERM') ~= 'linux' and os.getenv('NVIM_NF'))
    and ' '
  or ''

vis.events.subscribe(vis.events.WIN_STATUS, function(win)
  local file = win.file
  local sel = win.selection
  local left, right = {}, {}

  if vis.win == win then
    table.insert(left, modes[vis.mode] or '')
  end
  table.insert(
    left,
    (file.name or '[No Name]')
      .. (file.modified and ' [+]' or '')
      .. (vis.recording and ' @' or '')
  )
  if win.git_branch then
    table.insert(left, branch_icon .. win.git_branch)
  end

  local keys = vis.input_queue
  if keys ~= '' then
    table.insert(right, keys)
  elseif vis.count then
    table.insert(right, tostring(vis.count))
  end
  if #win.selections > 1 then
    table.insert(right, sel.number .. '/' .. #win.selections)
  end
  if win.spell then
    table.insert(right, 'spell:' .. win.spell)
  end
  table.insert(right, win.syntax or 'none')
  table.insert(
    right,
    (win.options.expandtab and 'spc:' or 'tab:') .. win.options.tabwidth
  )
  local size = file.size
  local pct = size == 0 and 0 or math.ceil((sel.pos or 0) / size * 100)
  table.insert(right, string.format('%d:%d %d%%', sel.line, sel.col, pct))

  win:status(
    ' ' .. table.concat(left, '  ') .. ' ',
    ' ' .. table.concat(right, '  ') .. ' '
  )
  -- Stop propagation so vis' default statusline doesn't run
  return true
end, 1)
