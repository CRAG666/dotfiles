-- Port of the keymaps and abbreviations in nvim's `after/ftplugin/*`

-- python: autocorrect booleans outside comments and strings {{{
local python_corrections = {
  ['true'] = 'True',
  ture = 'True',
  ['false'] = 'False',
  flase = 'False',
}

---Lexer tag of the char before byte `pos` of `file`, using up to 32KiB of
---context like vis' highlighter
---@param file table
---@param pos integer
---@param syntax string
---@return string?
local lexers = {}

local function tag_at(file, pos, syntax)
  -- A private instance: vis-spellcheck wraps `lex` of the cached one and
  -- tags typos inside strings and comments as errors
  if lexers[syntax] == nil then
    -- Without lpeg or the lexer there is no syntax to tell comments apart
    local ok, lexer = pcall(vis.lexers.load, syntax)
    lexers[syntax] = ok and lexer or false
  end
  local lexer = lexers[syntax]
  if not lexer then
    return nil
  end
  local start = math.max(0, pos - 32768)
  -- Include text after the cursor so strings and comments are closed
  local finish = math.min(file.size, pos + 1024)
  local tokens = lexer:lex(file:content(start, finish - start), 1)
  for i = 1, #tokens, 2 do
    if tokens[i + 1] > pos - start then
      return tokens[i]
    end
  end
end

vis.events.subscribe(vis.events.INPUT, function(key)
  local win = vis.win
  if
    vis.mode ~= vis.modes.INSERT
    or not win
    or win.syntax ~= 'python'
    or key:find('^[%w_]')
    or #win.selections > 1
  then
    return
  end
  local sel = win.selection
  local word = win.file.lines[sel.line]:sub(1, sel.col - 1):match('[%w_]+$')
  local correction = word and python_corrections[word]
  if not correction then
    return
  end
  local pos = sel.pos
  local tag = tag_at(win.file, pos, 'python')
  if not tag or tag:find('^comment') or tag:find('^string') then
    return
  end
  win.file:delete(pos - #word, #word)
  win.file:insert(pos - #word, correction)
  sel.pos = pos
end)
-- }}}

-- csharp: append `;` to the line, keeping the cursor {{{
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  if win.syntax ~= 'csharp' then
    return
  end
  win:map(vis.modes.NORMAL, ' ;', function()
    local sel = win.selection
    local lnum, col = sel.line, sel.col
    win.file.lines[lnum] = win.file.lines[lnum] .. ';'
    sel:to(lnum, col)
  end, 'Append ; to the line')
end)
-- }}}

-- vim:ts=2:sw=2:sts=2:fdm=marker
