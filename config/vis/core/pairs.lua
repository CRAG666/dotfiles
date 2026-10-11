-- Port of ultimate-autopair.nvim's basics: close brackets and quotes, type
-- over closers and delete empty pairs; single selection only

local pairs_by_open = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}
local closers = { [')'] = true, [']'] = true, ['}'] = true }

---@param char string
---@return boolean
local function before_closable(char)
  return char == '' or char:find('%s') ~= nil or closers[char] ~= nil
end

vis.events.subscribe(vis.events.INPUT, function(key)
  local win = vis.win
  if vis.mode ~= vis.modes.INSERT or not win or #win.selections > 1 then
    return
  end
  local file = win.file
  local pos = win.selection.pos
  local next_char = file:content(pos, 1)
  local prev_char = pos > 0 and file:content(pos - 1, 1) or ''

  -- Type over an existing closer
  if key == next_char and (closers[key] or pairs_by_open[key] == key) then
    win.selection.pos = pos + 1
    return true
  end

  local close = pairs_by_open[key]
  if not close or not before_closable(next_char) then
    return
  end
  -- Quotes after a word char are apostrophes or closing quotes
  if close == key and prev_char:find('[%w_]') then
    return
  end
  file:insert(pos, key .. close)
  win.selection.pos = pos + 1
  return true
end)

vis:map(vis.modes.INSERT, '<Backspace>', function()
  local win = vis.win
  local pos = win.selection.pos
  if #win.selections == 1 and pos and pos > 0 then
    local around = win.file:content(pos - 1, 2)
    if pairs_by_open[around:sub(1, 1)] == around:sub(2, 2) then
      win.file:delete(pos - 1, 2)
      win.selection.pos = pos - 1
      return
    end
  end
  vis:feedkeys('<vis-delete-char-prev>')
end, 'Delete previous char, or the empty pair around the cursor')
