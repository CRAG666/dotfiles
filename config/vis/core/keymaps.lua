-- Port of nvim's `core/keymaps.lua`
-- Leader is <Space>, localleader is `\`, as in nvim

local util = require('core.util')
local map = util.map

local N, V, I = vis.modes.NORMAL, vis.modes.VISUAL, vis.modes.INSERT

---Run `action` with register `reg` unless the user picked one explicitly
---@param reg string
---@param action string
---@return function
local function with_default_register(reg, action)
  return function()
    if vis.register == '"' then
      vis.register = reg
    end
    vis:feedkeys(action)
  end
end

-- Use system clipboard (`clipboard = 'unnamedplus'`)
-- stylua: ignore start
map({ N, V }, 'y', with_default_register('+', '<vis-operator-yank>'), 'Yank to clipboard')
map({ N, V }, 'd', with_default_register('+', '<vis-operator-delete>'), 'Delete to clipboard')
map({ N },    'p', with_default_register('+', '<vis-put-after>'), 'Put from clipboard')
map({ N },    'P', with_default_register('+', '<vis-put-before>'), 'Put from clipboard')
-- Replace selection without yanking it (`"_dP`)
map({ V },    'p', with_default_register('+', '<vis-put-after>'), 'Replace selection with clipboard')
map({ V },    'P', with_default_register('+', '<vis-put-before>'), 'Replace selection with clipboard')

-- No yank
map({ N },    'x', with_default_register('_', '<vis-delete-char-next>'), 'Delete char without yanking')
map({ N, V }, 'c', with_default_register('_', '<vis-operator-change>'), 'Change without yanking')
map({ N },    'C', with_default_register('_', '<vis-operator-change>$'), 'Change to end of line without yanking')
-- stylua: ignore end

-- Insert on an empty line starts at the right indentation (`"_cc`)
map(N, 'i', function()
  local win = vis.win
  local line = win.file.lines[win.selection.line]
  if #win.selections == 1 and line == '' then
    vis.register = '_'
    vis:feedkeys('<vis-operator-change><vis-operator-change>')
  else
    vis:feedkeys('<vis-mode-insert>')
  end
end, 'Insert, indenting empty lines')

-- More consistent behavior on wrapped lines: vis always soft-wraps
for _, mode in ipairs({ N, V }) do
  map(mode, 'j', function()
    vis:feedkeys(
      vis.count and '<vis-motion-line-down>' or '<vis-motion-screenline-down>'
    )
  end, 'Move down')
  map(mode, 'k', function()
    vis:feedkeys(
      vis.count and '<vis-motion-line-up>' or '<vis-motion-screenline-up>'
    )
  end, 'Move up')
end

-- <C-d>/<C-u>/<Tab>/<S-Tab> manage multiple selections in vis; keep that when
-- there are several selections, otherwise behave as in nvim
---@param multi string keys with multiple selections
---@param single string keys with a single selection
---@return function
local function on_selections(multi, single)
  return function()
    vis:feedkeys(#vis.win.selections > 1 and multi or single)
  end
end

-- stylua: ignore start
map(N, '<C-d>', on_selections('<vis-selection-next>', '<vis-window-halfpage-down><vis-window-redraw-center>'), 'Half page down and center')
map(N, '<C-u>', on_selections('<vis-selection-prev>', '<vis-window-halfpage-up><vis-window-redraw-center>'), 'Half page up and center')
map(N, '<Tab>', on_selections('<vis-selections-align>', '<vis-window-next>'), 'Next window')
map(N, '<S-Tab>', on_selections('<vis-selections-align-indent-right>', '<vis-window-prev>'), 'Previous window')
map(N, 'n', '<vis-motion-search-repeat-forward><vis-window-redraw-center>', 'Next match and center')
map(N, 'N', '<vis-motion-search-repeat-backward><vis-window-redraw-center>', 'Previous match and center')

-- Enter insert mode, add a space after the cursor
map(N, '<M-i>', '<vis-mode-insert> <Left>', 'Insert with a space after the cursor')
map(N, '<M-I>', '<vis-insert-line-start> <Left>', 'Insert at start of line with a space after the cursor')
map(N, '<M-a>', '<vis-append-char-next> <Left>', 'Append with a space after the cursor')
map(N, '<M-A>', '<vis-append-line-end> <Left>', 'Append at end of line with a space after the cursor')
-- stylua: ignore end

-- Move lines (mini.move)
---@param dir -1|1
local function move_line(dir)
  local win = vis.win
  local lines = win.file.lines
  local sel = win.selection
  local from, to = sel.line, sel.line + dir
  if to < 1 or to > #lines then
    return
  end
  local col = sel.col
  lines[from], lines[to] = lines[to], lines[from]
  sel:to(to, col)
end
map(N, '<M-j>', function()
  move_line(1)
end, 'Move line down')
map(N, '<M-k>', function()
  move_line(-1)
end, 'Move line up')

---Move the lines covered by the selection, keeping them selected
---@param dir -1|1
local function move_selection(dir)
  local win = vis.win
  local file = win.file
  local lines = file.lines
  local range = win.selection.range
  local first = file:line_column_from_offset(range.start)
  local last =
    file:line_column_from_offset(math.max(range.start, range.finish - 1))
  local swap = dir > 0 and last + 1 or first - 1
  if swap < 1 or swap > #lines then
    return
  end
  local moved = lines[swap]
  for i = swap, dir > 0 and first + 1 or last - 1, -dir do
    lines[i] = lines[i - dir]
  end
  lines[dir > 0 and first or last] = moved
  first, last = first + dir, last + dir
  win.selection.range = {
    start = file:offset_from_line_column(first, 1),
    finish = file:offset_from_line_column(last, 1) + #lines[last],
  }
end
-- stylua: ignore start
map(V, '<M-j>', function() move_selection(1) end, 'Move selection down')
map(V, '<M-k>', function() move_selection(-1) end, 'Move selection up')
map(N, '<M-h>', '<vis-operator-shift-left><vis-operator-shift-left>', 'Move line left')
map(N, '<M-l>', '<vis-operator-shift-right><vis-operator-shift-right>', 'Move line right')
map(V, '<M-h>', '<vis-operator-shift-left>gv', 'Move selection left')
map(V, '<M-l>', '<vis-operator-shift-right>gv', 'Move selection right')
-- stylua: ignore end

-- Text object: current buffer
vis:textobject_new('af', function(win)
  return 0, win.file.size
end, 'Select current buffer')
vis:textobject_new('if', function(win)
  return 0, win.file.size
end, 'Select current buffer')

-- Go to the first/last line of current paragraph
---@param dir -1|1
---@return function
local function paragraph_edge(dir)
  return function(win, pos)
    local file = win.file
    local lines = file.lines
    local lnum = file:line_column_from_offset(pos)
    local count = vis.count or 1
    -- Already on the edge: move into the next paragraph first
    if lines[lnum + dir] == '' and lines[lnum] ~= '' then
      lnum = lnum + dir
    end
    while count > 0 do
      while lines[lnum] == '' and lines[lnum + dir] ~= nil do
        lnum = lnum + dir
      end
      while lines[lnum + dir] ~= nil and lines[lnum + dir] ~= '' do
        lnum = lnum + dir
      end
      count = count - 1
      if count > 0 and lines[lnum + dir] ~= nil then
        lnum = lnum + dir
      end
    end
    return file:offset_from_line_column(lnum, 1)
  end
end
vis:motion_new('g{', paragraph_edge(-1), 'Go to the first line of paragraph')
vis:motion_new('g}', paragraph_edge(1), 'Go to the last line of paragraph')

-- Jump to git conflict markers
---@param marker string
---@param dir -1|1
---@return function
local function conflict_marker(marker, dir)
  local pattern = '^' .. string.rep(marker, 7)
  return function(win, pos)
    local file = win.file
    local lines = file.lines
    local lnum = file:line_column_from_offset(pos) + dir
    while lines[lnum] ~= nil do
      if lines[lnum]:find(pattern) then
        return file:offset_from_line_column(lnum, 1)
      end
      lnum = lnum + dir
    end
    return pos
  end
end
-- stylua: ignore start
vis:motion_new('[<', conflict_marker('<', -1), 'Go to previous git conflict start')
vis:motion_new(']<', conflict_marker('<', 1),  'Go to next git conflict start')
vis:motion_new('[>', conflict_marker('>', -1), 'Go to previous git conflict end')
vis:motion_new(']>', conflict_marker('>', 1),  'Go to next git conflict end')
vis:motion_new('[x', conflict_marker('=', -1), 'Go to previous git conflict mid')
vis:motion_new(']x', conflict_marker('=', 1),  'Go to next git conflict mid')
vis:motion_new('[|', conflict_marker('|', -1), 'Go to previous git conflict base')
vis:motion_new(']|', conflict_marker('|', 1),  'Go to next git conflict base')
-- stylua: ignore end

-- Go to file under cursor, with line number (`gF`)
local function goto_file()
  local win = vis.win
  local line = win.file.lines[win.selection.line]
  local col = win.selection.col
  local s = col
  while s > 1 and line:sub(s - 1, s - 1):find('[^%s"\'`()<>%[%]]') do
    s = s - 1
  end
  local target = line:sub(s):match('^[^%s"\'`()<>%[%]]+')
  if not target then
    return
  end
  local path, lnum = target:match('^(.-):(%d+)')
  path = path or target:gsub(':$', '')
  if path:sub(1, 1) == '~' then
    path = os.getenv('HOME') .. path:sub(2)
  elseif path:sub(1, 1) ~= '/' and win.file.path then
    local dir = win.file.path:match('^(.*)/')
    local candidate = dir .. '/' .. path
    if util.exists(candidate) then
      path = candidate
    end
  end
  if not util.exists(path) then
    vis:info('File not found: ' .. path)
    return
  end
  vis:command('e ' .. util.shellescape(path))
  if lnum then
    vis.win.selection:to(tonumber(lnum), 1)
  end
end
map(N, 'gf', goto_file, 'Go to file under cursor')
map(N, ']f', goto_file, 'Go to file under cursor')

-- Surround selections, vis-surround only provides `cs`/`ds`
local surround_pairs = {
  ['('] = { '(', ')' },
  [')'] = { '(', ')' },
  ['['] = { '[', ']' },
  [']'] = { '[', ']' },
  ['{'] = { '{', '}' },
  ['}'] = { '{', '}' },
  ['<'] = { '<', '>' },
  ['>'] = { '<', '>' },
  -- Markdown bold (nvim-surround `<M-*>`)
  ['<M-*>'] = { '**', '**' },
}
map(V, 'S', function(keys)
  if #keys < 1 then
    return -1
  end
  local key = keys:match('^<[^>]+>') or keys:sub(1, 1)
  local pair = surround_pairs[key] or { key, key }
  local win = vis.win
  local ranges = {}
  for sel in win:selections_iterator() do
    table.insert(ranges, sel.range)
  end
  -- Insert from the end so earlier offsets stay valid
  table.sort(ranges, function(a, b)
    return a.start > b.start
  end)
  for _, r in ipairs(ranges) do
    win.file:insert(r.finish, pair[2])
    win.file:insert(r.start, pair[1])
  end
  vis.mode = vis.modes.NORMAL
  return #key
end, 'Surround selection')

-- Yank paragraphs as single lines, useful for yanking hard-wrapped
-- paragraphs and pasting them in browsers or other editors
---@param syntax string?
---@param line string
---@return boolean
local function should_join_line(syntax, line)
  if syntax == 'markdown' or syntax == 'text' then
    local bullet = syntax == 'markdown' and '^%s*[-*#]%s+' or '^%s*[-*]%s+'
    return line ~= ''
      and not line:match(bullet)
      and not line:match('^%s*%d+%.%s+')
  end
  return line ~= ''
end

vis:operator_new('gy', function(file, range, pos)
  local syntax = vis.win.syntax
  local joined = {} ---@type string[]
  local text = file:content(range)
  for line in (text .. '\n'):gmatch('(.-)\n') do
    -- Start a new paragraph on empty lines so the original ones are kept
    if line == '' then
      table.insert(joined, '')
    end
    if not should_join_line(syntax, line) then
      table.insert(joined, line)
    else
      local last = table.remove(joined)
      local trimmed = line:match('^%s*(.-)%s*$')
      table.insert(
        joined,
        (last == nil or last == '') and trimmed or last .. ' ' .. trimmed
      )
    end
  end
  local result = table.concat(joined, '\n')
  vis.registers['+'] = { result }
  vis.registers['"'] = { result }
  return pos
end, 'Yank text with joined paragraphs')

-- Yank line and comment it out (`yygccp`)
map(N, 'yc', function()
  local win = vis.win
  local lnum = win.selection.line
  local line = win.file.lines[lnum]
  vis.registers['+'] = { line .. '\n' }
  win.file:insert(
    win.file:offset_from_line_column(lnum + 1, 1) or win.file.size,
    line .. '\n'
  )
  require('core.comment').toggle(win, lnum, lnum)
  win.selection:to(lnum + 1, win.selection.col)
end, 'Yank [c]omment')

-- Edit current file's directory
map(N, '-', function()
  local path = vis.win.file.path
  require('core.pick').explore(path and path:match('^(.*)/') or '.')
end, "Edit current file's directory")

-- Search and replace with structural regular expressions
-- stylua: ignore start
map(N, ' rr', ':,x/', 'Search and [r]eplace')
map(N, ' rl', ':x/', 'Search and [r]eplace [l]ine')
map(V, ' rr', ':x/', 'Search and [r]eplace visual')
map(N, ' rn', '*N<vis-operator-change>gn', 'Search and replace word, repeat with .')
map(N, ' rN', '#N<vis-operator-change>gN', 'Search and replace word backwards, repeat with .')
map(N, ' re', ':,x/^.*$/ a/', 'Search and [r]eplace [e]xtend')
map(V, ' re', ':x/^.*$/ a/', 'Search and [r]eplace [e]xtend visual')
-- stylua: ignore end
map(N, ' rw', function()
  local win = vis.win
  local line = win.file.lines[win.selection.line]
  local col = win.selection.col
  local s, e = col, col
  while s > 1 and line:sub(s - 1, s - 1):find('[%w_]') do
    s = s - 1
  end
  while line:sub(e, e):find('[%w_]') do
    e = e + 1
  end
  local word = line:sub(s, e - 1)
  if word == '' then
    return
  end
  vis:feedkeys(':,x/\\<' .. word .. '\\>/ c/')
end, 'Search and [r]eplace [w]ord')

-- Spell checker (vis-spellcheck)
local spell_langs = { 'es_MX', 'en_US' }
map(N, '\\s', function()
  local win = vis.win
  if win.spell then
    win.spell = nil
    vis:feedkeys('<C-w>d')
    return
  end
  local lang = require('core.pick').select(spell_langs, 'Spell language')
  if not lang then
    vis:info('language not selected')
    return
  end
  vis:command('set spelllang ' .. lang)
  win.spell = lang
  vis:feedkeys('<C-w>e')
end, 'Toggle spell checker')

-- Insert mode readline keys (readline.lua), vis already has <C-a>/<C-e>/<C-w>
map(I, '<C-b>', '<vis-motion-char-prev>', 'Move left')
map(I, '<C-f>', '<vis-motion-char-next>', 'Move right')
map(I, '<M-b>', '<vis-motion-word-start-prev>', 'Move to previous word')
map(I, '<M-f>', '<vis-motion-word-end-next>', 'Move to next word')

map(N, '<Backspace>', function()
  require('core.pick').alternate()
end, 'Back to previous file')

-- vis has no tabs, jump to windows instead
for i = 1, 9 do
  map(N, ' ' .. i, function()
    local n = 0
    for win in vis:windows() do
      n = n + 1
      if n == i then
        vis.win = win
        return
      end
    end
  end, 'Jump to window ' .. i)
end

-- Command-line abbreviations for shell commands (`:rm` -> `:!rm`)
for _, cmd in ipairs({
  'man',
  'rm',
  'mv',
  'git',
  'tree',
  'mkdir',
  'touch',
  'chmod',
}) do
  vis:command_register(cmd, function(argv)
    local args = {}
    for _, arg in ipairs(argv) do
      table.insert(args, arg:find('%s') and util.shellescape(arg) or arg)
    end
    return vis:command('!' .. cmd .. ' ' .. table.concat(args, ' '))
  end, 'Run `' .. cmd .. '` in the shell')
end
