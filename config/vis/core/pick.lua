-- Port of the snacks.nvim picker keymaps, built on fzf, fd, rg and yazi

local util = require('core.util')
local map = util.map
local sh = util.shellescape

local N, V = vis.modes.NORMAL, vis.modes.VISUAL

local M = {}

local fzf_opts = '--border=sharp --margin=0 --padding=0 --reverse'
local preview =
  "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
local grep_preview = "--delimiter : --preview 'bat --color=always --style=numbers"
  .. " --highlight-line {2} {1}' --preview-window '+{2}/2'"
local rg = 'rg --column --line-number --no-heading --color=always --smart-case'

---Run `cmd` (which should end in fzf) in fullscreen and return its output
---@param cmd string
---@return string? selection
function M.run(cmd)
  local status, out = vis:pipe(cmd, true)
  vis:redraw()
  if status ~= 0 or not out or out == '' then
    return nil
  end
  return (out:gsub('\n$', ''))
end

---Pick one of `items`, `vim.ui.select` equivalent
---@param items string[]
---@param prompt? string
---@return string?
function M.select(items, prompt)
  local input = table.concat(items, '\n')
  local status, out = vis:pipe(
    input,
    string.format(
      'fzf %s --prompt %s',
      fzf_opts,
      sh((prompt or 'Select') .. ': ')
    ),
    true
  )
  vis:redraw()
  if status ~= 0 or not out or out == '' then
    return nil
  end
  return (out:gsub('\n$', ''))
end

---Open `path` in the current window, or a new one if it has unsaved changes
---@param path string
---@param lnum? integer
---@param col? integer
function M.open(path, lnum, col)
  local win = vis.win
  local cmd = (win and win.file.modified) and 'o' or 'e'
  if not vis:command(cmd .. ' ' .. sh(path)) then
    return
  end
  if lnum then
    vis.win.selection:to(lnum, col or 1)
    vis:feedkeys('<vis-window-redraw-center>')
  end
end

---Open a `file:line:col:text` grep result
---@param result string?
---@param dir? string directory the paths are relative to
local function open_grep_result(result, dir)
  if not result then
    return
  end
  local path, lnum, col = result:match('^(.-):(%d+):(%d+):')
  if not path then
    return
  end
  if dir and path:sub(1, 1) ~= '/' then
    path = dir .. '/' .. path
  end
  M.open(path, tonumber(lnum), tonumber(col))
end

---Root directory of the current file's project
---@return string
local function root_dir()
  local dir = util.file_dir(vis.win)
  return util.root(dir, util.root_markers) or dir
end

---Find files under `dir`
---@param dir string
function M.files(dir)
  local out = M.run(
    string.format(
      'cd %s && fd --type f --hidden --exclude .git | fzf %s %s --prompt %s',
      sh(dir),
      fzf_opts,
      preview,
      sh('Files ' .. util.tilde(dir) .. '> ')
    )
  )
  if out then
    M.open(dir .. '/' .. out)
  end
end

---Live grep under `dir`
---@param dir string
---@param query? string initial query
function M.grep(dir, query)
  local reload = string.format('[ -n {q} ] && %s -- {q} || true', rg)
  local out = M.run(
    string.format(
      'cd %s && fzf %s --ansi --disabled --query %s --bind %s --bind %s'
        .. ' %s --prompt %s',
      sh(dir),
      fzf_opts,
      sh(query or ''),
      sh('start:reload:' .. reload),
      sh('change:reload:' .. reload),
      grep_preview,
      sh('Grep> ')
    )
  )
  open_grep_result(out, dir)
end

-- Most recently used files {{{
local state_dir = (
  os.getenv('XDG_STATE_HOME') or os.getenv('HOME') .. '/.local/state'
) .. '/vis'
local mru_path = state_dir .. '/mru'
local mru_max = 200

---@return string[]
local function mru_read()
  local list = {}
  local f = io.open(mru_path, 'r')
  if not f then
    return list
  end
  for line in f:lines() do
    table.insert(list, line)
  end
  f:close()
  return list
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  local path = win.file.path
  if not path then
    return
  end
  local list = { path }
  for _, p in ipairs(mru_read()) do
    if p ~= path and #list < mru_max then
      table.insert(list, p)
    end
  end
  local f = io.open(mru_path, 'w')
  if not f then
    os.execute('mkdir -p ' .. sh(state_dir))
    f = io.open(mru_path, 'w')
  end
  if f then
    f:write(table.concat(list, '\n'), '\n')
    f:close()
  end
end)

function M.recent()
  local current = vis.win and vis.win.file.path
  local list = {}
  for _, p in ipairs(mru_read()) do
    if p ~= current and util.exists(p) then
      table.insert(list, util.tilde(p))
    end
  end
  local choice = M.select(list, 'Recent')
  if choice then
    M.open((choice:gsub('^~', os.getenv('HOME'))))
  end
end

---Open the most recently opened file other than the current one (`:b#`)
function M.alternate()
  local current = vis.win and vis.win.file.path
  for _, p in ipairs(mru_read()) do
    if p ~= current and util.exists(p) then
      M.open(p)
      return
    end
  end
  vis:info('No alternate file')
end
-- }}}

---File explorer, replaces netrw/snacks explorer
---@param dir string
function M.explore(dir)
  local tmp = os.tmpname()
  vis:pipe(
    string.format(
      'yazi --chooser-file=%s %s </dev/tty >/dev/tty 2>&1',
      sh(tmp),
      sh(dir)
    ),
    true
  )
  vis:redraw()
  local f = io.open(tmp, 'r')
  local path = f and f:read('*l')
  if f then
    f:close()
  end
  os.remove(tmp)
  if path and path ~= '' then
    M.open(path)
  end
end

function M.buffers()
  local wins, names = {}, {}
  for win in vis:windows() do
    if win ~= vis.win and win.file.name then
      table.insert(wins, win)
      table.insert(names, string.format('%d\t%s', #wins, win.file.name))
    end
  end
  local choice = M.select(names, 'Buffers')
  local idx = choice and tonumber(choice:match('^(%d+)'))
  if idx then
    vis.win = wins[idx]
  end
end

function M.buffer_lines()
  local status, out = vis:pipe(
    vis.win.file,
    { start = 0, finish = vis.win.file.size },
    string.format(
      'nl -ba -w1 -s: | fzf %s --delimiter : --nth 2.. --prompt %s',
      fzf_opts,
      sh('Lines> ')
    ),
    true
  )
  vis:redraw()
  local lnum = status == 0 and out and tonumber(out:match('^(%d+):'))
  if lnum then
    vis.win.selection:to(lnum, 1)
    vis:feedkeys('<vis-window-redraw-center>')
  end
end

---@return string?
local function word_under_cursor()
  local win = vis.win
  local line = win.file.lines[win.selection.line]
  local s, e = win.selection.col, win.selection.col
  while s > 1 and line:sub(s - 1, s - 1):find('[%w_]') do
    s = s - 1
  end
  while line:sub(e, e):find('[%w_]') do
    e = e + 1
  end
  local word = line:sub(s, e - 1)
  return word ~= '' and word or nil
end

-- Git {{{
---@param args string
---@return string
local function git(args)
  return string.format('git -C %s %s', sh(util.file_dir(vis.win)), args)
end

function M.git_files()
  local top = util.run(git('rev-parse --show-toplevel'))
  if not top then
    vis:info('Not a git repository')
    return
  end
  local out = M.run(
    string.format(
      'cd %s && git ls-files --cached --others --exclude-standard | fzf %s %s',
      sh(top),
      fzf_opts,
      preview
    )
  )
  if out then
    M.open(top .. '/' .. out)
  end
end

function M.git_status()
  local top = util.run(git('rev-parse --show-toplevel'))
  if not top then
    vis:info('Not a git repository')
    return
  end
  local out = M.run(
    string.format(
      'cd %s && git -c color.status=always status --short | fzf %s --ansi'
        .. " --preview 'git diff --color=always -- {-1}'",
      sh(top),
      fzf_opts
    )
  )
  local path = out and out:match('%S+$')
  if path then
    M.open(top .. '/' .. path)
  end
end

---@param file boolean only commits touching the current file
function M.git_log(file)
  -- The preview runs in its own shell, pass the path through the environment
  local path = file and vis.win.file.path or ''
  M.run(
    string.format(
      'cd %s && export VIS_LOG_FILE=%s && git log --color=always --oneline'
        .. ' ${VIS_LOG_FILE:+-- "$VIS_LOG_FILE"} | fzf %s --ansi --no-sort'
        .. " --preview 'git show --color=always {1}"
        .. ' ${VIS_LOG_FILE:+-- "$VIS_LOG_FILE"}\'',
      sh(util.file_dir(vis.win)),
      sh(path),
      fzf_opts
    )
  )
end

function M.git_branches()
  local out = M.run(
    git(
      string.format(
        "branch --all --format='%%(refname:short)' | fzf %s --prompt %s",
        fzf_opts,
        sh('Checkout> ')
      )
    )
  )
  if out then
    local result = util.run(git('checkout ' .. sh(out)))
    vis:info(
      result and ('Switched to ' .. out) or ('Failed to checkout ' .. out)
    )
  end
end
-- }}}

-- Keymaps {{{
-- stylua: ignore start
map(N, ' ,', M.buffers, 'Buffers')
map(N, ' /', function() M.grep(root_dir()) end, 'Grep')
map(N, ' .', function() M.explore(util.file_dir(vis.win)) end, 'File Explorer')
map(N, ' bd', ':q<Enter>', 'Delete Buffer')

map(N, ' fc', function() M.files(os.getenv('HOME') .. '/.config/vis') end, 'Find Config File')
map(N, ' fd', function() M.files(util.file_dir(vis.win)) end, 'Find Files in directory')
map(N, ' ff', function() M.files(root_dir()) end, 'Find Files in root path')
map(N, ' fg', M.git_files, 'Find Git Files')
map(N, ' fr', M.recent, 'Recent')

map(N, ' gb', M.git_branches, 'Git Branches')
map(N, ' gl', function() M.git_log(false) end, 'Git Log')
map(N, ' gf', function() M.git_log(true) end, 'Git Log File')
map(N, ' gt', M.git_status, 'Git Status')

map(N, ' sb', M.buffer_lines, 'Buffer Lines')
map(N, ' sg', function() M.grep(root_dir()) end, 'Grep')
map(N, ' sk', ':help<Enter>', 'Keymaps')
map({ N, V }, ' sw', function() M.grep(root_dir(), word_under_cursor()) end, 'Grep word under cursor')
-- stylua: ignore end
-- }}}

return M

-- vim:ts=2:sw=2:sts=2:fdm=marker
