local M = {}

M.root_markers = {
  '.git',
  '.svn',
  '.bzr',
  '.hg',
  '.project',
  '.pro',
  '.sln',
  '.vcxproj',
  'Makefile',
  'makefile',
  'MAKEFILE',
  'venv',
  'env',
  '.venv',
  '.env',
  '.gitignore',
  '.editorconfig',
  'README.md',
  'README.txt',
  'README.org',
}

---Read file contents
---@param path string
---@return string?
function M.read_file(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content or ''
end

---Write string into file
---@param path string
---@return boolean success
function M.write_file(path, str)
  local file = io.open(path, 'w')
  if not file then
    return false
  end
  file:write(str)
  file:close()
  return true
end

---Check if a path is empty
---@param path string
---@return boolean
function M.is_empty(path)
  local stat = vim.uv.fs_stat(path)
  return not stat or stat.size == 0
end

---Given a list of paths, return a list of path heads that uniquely distinguish each path
---e.g. { 'a/b/c', 'a/b/d', 'a/e/f' } -> { 'c', 'd', 'f' }
---     { 'a/b/c', 'd/b/c', 'e/c' } -> { 'a/b', 'd/b', 'e' }
---@param paths string[]
---@return string[]
function M.diff(paths)
  local n_paths = (function()
    local path_set = {}
    for _, path in ipairs(paths) do
      path_set[path] = true
    end
    return #vim.tbl_keys(path_set)
  end)()

  ---@alias ipath { [1]: string, [2]: integer }
  ---Paths with index
  ---@type ipath[]
  local ipaths = {}
  for i, path in ipairs(paths) do
    table.insert(ipaths, { path, i })
  end

  ---Groups of paths with the same tail
  ---key:val = tail:ihead[]
  ---@type table<string, ipath[]>
  local groups = { [''] = ipaths }

  while #vim.tbl_keys(groups) < n_paths do
    local g = {} ---@type table<string, ipath[]>
    for tail, iheads in pairs(groups) do
      for _, ihead in ipairs(iheads) do
        local head = ihead[1]
        local idx = ihead[2]
        local t = vim.fn.fnamemodify(head, ':t')
        local h = vim.fn.fnamemodify(head, ':h')
        if #vim.tbl_keys(groups) > 1 then
          t = t == '' and tail or tail == '' and t or vim.fs.joinpath(t, tail)
        end
        h = h == '.' and '' or h

        if not g[t] then
          g[t] = {}
        end
        table.insert(g[t], { h, idx })
      end
    end
    groups = g
  end

  local diffs = {}
  for tail, iheads in pairs(groups) do
    for _, ihead in ipairs(iheads) do
      diffs[ihead[2]] = tail
    end
  end
  return diffs
end

---Check if a given directory contains a file or subdirectory
---@param dir string directory path
---@param sub string sub file or directory path
function M.contains(dir, sub)
  -- `fnamemodify()` adds trailing `/` to directories
  -- `dir` must end with `/`, else when `sub` is `/foo/bar-baz/file.txt` and
  -- `dir` is `/foo/bar`, the function gives false positive
  dir = vim.fn.fnamemodify(vim.fs.normalize(dir), ':p')
  sub = vim.fn.fnamemodify(vim.fs.normalize(sub), ':p')
  return vim.startswith(sub, dir)
end

---Check if given directory is root directory
---@param dir string
---@return boolean
function M.is_root_dir(dir)
  return dir == vim.fs.dirname(dir)
end

---Home directory
---@type string?
local home

---Check if given directory is home directory
---@param dir string
---@return boolean
function M.is_home_dir(dir)
  if not home then
    home = vim.uv.os_homedir()
  end
  return dir == home
end

---Check if a path is full path
---@param path string
---@return boolean
function M.is_full_path(path)
  -- Use `fs.normalize()` to trim trailing slashes so that
  -- `foo/` and `foo` are treated equally
  return vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
    == vim.fs.normalize(path)
end

return M
