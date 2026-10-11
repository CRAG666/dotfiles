local M = {}

---Set a keymap in one or more modes
---@param modes integer|integer[]
---@param lhs string
---@param rhs string|function
---@param help? string
function M.map(modes, lhs, rhs, help)
  if type(modes) ~= 'table' then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    vis:map(mode, lhs, rhs, help)
  end
end

---@param path string
---@return boolean
function M.exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

---Quote a string for the shell
---@param s string
---@return string
function M.shellescape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

---Run a shell command and return its output without the trailing newline
---@param cmd string
---@return string? output nil if the command failed
function M.run(cmd)
  local f = io.popen(cmd .. ' 2>/dev/null')
  if not f then
    return nil
  end
  local out = f:read('*a')
  local ok = f:close()
  if not ok then
    return nil
  end
  return (out:gsub('\n$', ''))
end

local home = os.getenv('HOME')

---Replace the home directory prefix of `path` with `~`
---@param path string
---@return string
function M.tilde(path)
  if path:sub(1, #home + 1) == home .. '/' then
    return '~' .. path:sub(#home + 1)
  end
  return path
end

---Directory containing the file shown in `win`, or the cwd
---@param win table?
---@return string
function M.file_dir(win)
  local path = win and win.file.path
  return path and path:match('^(.*)/') or os.getenv('PWD') or '.'
end

---Find the closest ancestor of `dir` containing one of `markers`
---@param dir string
---@param markers string[]
---@return string?
function M.root(dir, markers)
  while dir and dir ~= '' do
    for _, marker in ipairs(markers) do
      if M.exists(dir .. '/' .. marker) then
        return dir
      end
    end
    dir = dir:match('^(.*)/[^/]*$')
  end
  return nil
end

M.root_markers = {
  '.git',
  '.hg',
  '.svn',
  '.bzr',
  'Makefile',
  'package.json',
  'pyproject.toml',
  'Cargo.toml',
  'go.mod',
}

return M
