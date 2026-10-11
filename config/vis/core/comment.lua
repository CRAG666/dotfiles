-- Comment toggling driven by each filetype's `commentstring`, see core/ft.lua
-- Same keys as nvim's builtin commenting: `gc{motion}`, `gcc`, visual `gc`

local M = {}

---@param s string
---@return string
local function pesc(s)
  return (s:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0'))
end

---@param win table
---@return string prefix, string suffix
local function parts(win)
  local cs = (win.ft and win.ft.commentstring) or '# %s'
  local prefix, suffix = cs:match('^(.-)%s*%%s%s*(.-)$')
  return prefix, suffix
end

---Toggle comments on lines `first`..`last` of the window's file
---@param win table
---@param first integer
---@param last integer
function M.toggle(win, first, last)
  local lines = win.file.lines
  local prefix, suffix = parts(win)
  local lpat = '^(%s*)' .. pesc(prefix) .. ' ?'
  local rpat = suffix ~= '' and (' ?' .. pesc(suffix) .. '%s*$') or nil

  -- Uncomment only if every non-blank line is commented
  local indent ---@type string?
  local commented = true
  for i = first, last do
    local line = lines[i]
    if line:find('%S') then
      local ws = line:match('^(%s*)')
      if not indent or #ws < #indent then
        indent = ws
      end
      if not line:find(lpat) then
        commented = false
      end
    end
  end
  if not indent then
    return
  end

  for i = first, last do
    local line = lines[i]
    if line:find('%S') then
      if commented then
        line = line:gsub(lpat, '%1', 1)
        if rpat then
          line = line:gsub(rpat, '', 1)
        end
      else
        line = indent
          .. prefix
          .. ' '
          .. line:sub(#indent + 1)
          .. (suffix ~= '' and ' ' .. suffix or '')
      end
      lines[i] = line
    end
  end
end

vis:operator_new('gc', function(file, range, pos)
  local win = vis.win
  local first = file:line_column_from_offset(range.start)
  local last =
    file:line_column_from_offset(math.max(range.start, range.finish - 1))
  M.toggle(win, first, last)
  return pos
end, 'Toggle comment')

vis:map(vis.modes.NORMAL, 'gcc', function()
  local win = vis.win
  local first, col = win.selection.line, win.selection.col
  local last = math.min(first + (vis.count or 1) - 1, #win.file.lines)
  M.toggle(win, first, last)
  -- Replacing lines invalidates the cursor, put it back explicitly
  win.selection:to(first, col)
end, 'Toggle comment line')

return M
