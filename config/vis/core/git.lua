-- Port of the gitsigns.nvim hunk actions; hunks are computed between the
-- buffer content and the index, as gitsigns does

local util = require('core.util')
local sh = util.shellescape
local map = util.map

local N, V = vis.modes.NORMAL, vis.modes.VISUAL

local M = {}

---@class Hunk
---@field old_start integer
---@field old_count integer
---@field new_start integer
---@field new_count integer
---@field lines string[] `@@` header followed by the hunk body

---Repository root and the file's path relative to it
---@param win table
---@return string? top, string? rel
local function repo_path(win)
  local path = win.file.path
  if not path then
    return
  end
  -- `--show-prefix` resolves symlinks like `--show-toplevel` does, the file
  -- path may go through a symlink (e.g. ~/.config/vis -> dotfiles)
  local out = util.run(
    string.format(
      'git -C %s rev-parse --show-toplevel --show-prefix',
      sh(util.file_dir(win))
    )
  )
  local top, prefix = (out or ''):match('^([^\n]+)\n?(.*)$')
  if not top then
    return
  end
  return top, prefix .. path:match('[^/]+$')
end

---@param diff string unified diff with zero context lines
---@return table<string, Hunk[]> hunks by file (`+++ b/<path>`)
local function parse(diff)
  local files = {}
  local hunks, hunk
  for line in diff:gmatch('([^\n]*)\n') do
    local path = line:match('^%+%+%+ b/(.*)$')
    local os_, oc, ns, nc = line:match('^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@')
    if line:match('^diff ') then
      hunks, hunk = nil, nil
    elseif path and not hunk then
      hunks = {}
      files[path] = hunks
    elseif os_ then
      hunk = nil
      -- Deleted files (`+++ /dev/null`) have no hunk list
      if hunks then
        hunk = {
          old_start = tonumber(os_),
          old_count = tonumber(oc) or 1,
          new_start = tonumber(ns),
          new_count = tonumber(nc) or 1,
          lines = { line },
        }
        table.insert(hunks, hunk)
      end
    elseif hunk then
      table.insert(hunk.lines, line)
    end
  end
  return files
end

---Hunks between the index and the buffer content of `win`
---@param win table
---@return Hunk[]? hunks, string? top, string? rel
local function buffer_hunks(win)
  local top, rel = repo_path(win)
  if not top or not rel then
    vis:info('Not a git repository')
    return
  end
  local file = win.file
  local status, out, err = vis:pipe(
    file,
    { start = 0, finish = file.size },
    string.format(
      't=$(mktemp) && git -C %s show %s >"$t" 2>/dev/null;'
        .. ' diff -U0 --label a/%s --label b/%s "$t" -; s=$?; rm -f "$t";'
        .. ' [ $s -le 1 ]',
      sh(top),
      sh(':' .. rel),
      sh(rel),
      sh(rel)
    )
  )
  if status ~= 0 then
    vis:info('git diff failed: ' .. (err or ''):match('[^\n]*'))
    return
  end
  return parse(out or '')[rel] or {}, top, rel
end

---@param hunk Hunk
---@return integer first, integer last lines covered in the buffer
local function hunk_lines(hunk)
  if hunk.new_count == 0 then
    local line = math.max(hunk.new_start, 1)
    return line, line
  end
  return hunk.new_start, hunk.new_start + hunk.new_count - 1
end

---Hunks overlapping buffer lines `first`..`last`
---@param win table
---@param first integer
---@param last integer
---@return Hunk[]? hunks, string? top, string? rel
local function hunks_in(win, first, last)
  local hunks, top, rel = buffer_hunks(win)
  if not hunks then
    return
  end
  local found = {}
  for _, hunk in ipairs(hunks) do
    local s, e = hunk_lines(hunk)
    if s <= last and e >= first then
      table.insert(found, hunk)
    end
  end
  if #found == 0 then
    vis:info('No hunk here')
    return
  end
  return found, top, rel
end

---@param win table
---@return integer first, integer last lines of the selection
local function selected_lines(win)
  local sel = win.selection
  local range = sel.range
  if vis.mode == V or vis.mode == vis.modes.VISUAL_LINE then
    local file = win.file
    return file:line_column_from_offset(range.start),
      file:line_column_from_offset(math.max(range.start, range.finish - 1))
  end
  return sel.line, sel.line
end

---@param rel string
---@param hunks Hunk[]
---@return string
local function patch(rel, hunks)
  local parts = { '--- a/' .. rel, '+++ b/' .. rel }
  for _, hunk in ipairs(hunks) do
    table.insert(parts, table.concat(hunk.lines, '\n'))
  end
  return table.concat(parts, '\n') .. '\n'
end

---@param top string
---@param text string
---@param args string
---@return boolean
local function apply(top, text, args)
  local status, _, err = vis:pipe(
    text,
    string.format(
      'git -C %s apply --cached --unidiff-zero %s -',
      sh(top),
      args
    )
  )
  if status ~= 0 then
    vis:info('git apply failed: ' .. (err or ''):match('[^\n]*'))
  end
  return status == 0
end

---@type { top: string, text: string }?
local last_staged

---Stage the hunks under the cursor or the selection
function M.stage_hunk()
  local win = vis.win
  local first, last = selected_lines(win)
  vis.mode = N
  local top, rel = repo_path(win)
  if not top or not rel then
    vis:info('Not a git repository')
    return
  end
  -- Untracked files have no index entry to diff against
  util.run(
    string.format('git -C %s add --intent-to-add -- %s', sh(top), sh(rel))
  )
  local hunks
  hunks, top, rel = hunks_in(win, first, last)
  if not hunks or not top or not rel then
    return
  end
  local text = patch(rel, hunks)
  if apply(top, text, '') then
    last_staged = { top = top, text = text }
    vis:info('Staged ' .. #hunks .. ' hunk(s)')
  end
end

function M.undo_stage_hunk()
  if not last_staged then
    vis:info('Nothing to undo')
    return
  end
  if apply(last_staged.top, last_staged.text, '--reverse') then
    last_staged = nil
    vis:info('Unstaged last hunk')
  end
end

---Restore the hunks under the cursor or the selection from the index
function M.reset_hunk()
  local win = vis.win
  local first, last = selected_lines(win)
  vis.mode = N
  local hunks = hunks_in(win, first, last)
  if not hunks then
    return
  end
  local file = win.file
  -- Bottom-up so earlier line numbers stay valid
  for i = #hunks, 1, -1 do
    local hunk = hunks[i]
    local old = {}
    for _, line in ipairs(hunk.lines) do
      local removed = line:match('^%-(.*)$')
      if removed then
        table.insert(old, removed .. '\n')
      end
    end
    local start_line = hunk.new_count == 0 and hunk.new_start + 1
      or hunk.new_start
    local start = file:offset_from_line_column(start_line, 1) or file.size
    local finish = start
    if hunk.new_count > 0 then
      finish = file:offset_from_line_column(start_line + hunk.new_count, 1)
        or file.size
      file:delete(start, finish - start)
    end
    file:insert(start, table.concat(old))
  end
  win.selection:to(math.min(first, #file.lines), 1)
end

function M.preview_hunk()
  local win = vis.win
  local hunks = hunks_in(win, win.selection.line, win.selection.line)
  if hunks then
    vis:message(table.concat(hunks[1].lines, '\n'))
  end
end

function M.list_file_hunks()
  local win = vis.win
  local hunks = buffer_hunks(win)
  if not hunks or #hunks == 0 then
    vis:info('No hunks')
    return
  end
  local items = {}
  for _, hunk in ipairs(hunks) do
    table.insert(
      items,
      string.format('%d: %s', (hunk_lines(hunk)), hunk.lines[2] or '')
    )
  end
  local choice = require('core.pick').select(items, 'Hunks')
  local lnum = choice and tonumber(choice:match('^(%d+):'))
  if lnum then
    win.selection:to(lnum, 1)
    vis:feedkeys('<vis-window-redraw-center>')
  end
end

function M.list_repo_hunks()
  local dir = util.file_dir(vis.win)
  local top =
    util.run(string.format('git -C %s rev-parse --show-toplevel', sh(dir)))
  if not top then
    vis:info('Not a git repository')
    return
  end
  local diff =
    util.run(string.format('git -C %s diff -U0 --no-color', sh(top)))
  local items = {}
  for path, hunks in pairs(parse((diff or '') .. '\n')) do
    for _, hunk in ipairs(hunks) do
      table.insert(
        items,
        string.format(
          '%s:%d: %s',
          path,
          (hunk_lines(hunk)),
          hunk.lines[2] or ''
        )
      )
    end
  end
  if #items == 0 then
    vis:info('No hunks')
    return
  end
  table.sort(items)
  local pick = require('core.pick')
  local choice = pick.select(items, 'Repo hunks')
  local path, lnum = (choice or ''):match('^(.-):(%d+):')
  if path then
    pick.open(top .. '/' .. path, tonumber(lnum))
  end
end

---Run `git <args> -- <file>` for the current file
---@param args string
---@param msg string
---@return function
local function git_file(args, msg)
  return function()
    local top, rel = repo_path(vis.win)
    if not top or not rel then
      vis:info('Not a git repository')
      return
    end
    local ok =
      util.run(string.format('git -C %s %s -- %s', sh(top), args, sh(rel)))
    vis:info(ok and msg or ('git ' .. args .. ' failed'))
  end
end

---Replace the buffer content with the index version
function M.reset_buffer()
  local win = vis.win
  local top, rel = repo_path(win)
  if not top or not rel then
    vis:info('Not a git repository')
    return
  end
  local content =
    util.run(string.format('git -C %s show %s', sh(top), sh(':' .. rel)))
  if not content then
    vis:info(rel .. ' is not in the index')
    return
  end
  local file = win.file
  local line = win.selection.line
  file:delete(0, file.size)
  -- `util.run` strips the trailing newline
  file:insert(0, content .. '\n')
  win.selection:to(math.min(line, #file.lines), 1)
end

-- stylua: ignore start
map({ N, V }, ' gs', M.stage_hunk, 'Git stage current hunk')
map({ N, V }, ' gr', M.reset_hunk, 'Git reset current hunk')
map(N, ' gu', M.undo_stage_hunk, 'Git unstage current hunk')
map(N, ' gp', M.preview_hunk, 'Git preview current hunk')
map(N, ' gh', M.list_file_hunks, 'Git list file hunks')
map(N, ' gH', M.list_repo_hunks, 'Git list repo hunks')
map(N, ' gS', git_file('add', 'Staged buffer'), 'Git stage current buffer')
map(N, ' gU', git_file('reset -q', 'Unstaged buffer'), 'Git unstage current buffer')
map(N, ' gR', M.reset_buffer, 'Git reset current buffer')
-- stylua: ignore end

return M
