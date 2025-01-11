local M = {}

M.root_patterns = {
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
  local _paths = {}
  for _, path in ipairs(paths) do
    _paths[path] = true
  end
  local num_unique_paths = #vim.tbl_keys(_paths)

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

  while #vim.tbl_keys(groups) < num_unique_paths do
    local _groups = {}
    for tail, iheads in pairs(groups) do
      for _, ihead in ipairs(iheads) do
        local head = ihead[1]
        local idx = ihead[2]
        local _tail = vim.fn.fnamemodify(head, ':t')
        local _head = vim.fn.fnamemodify(head, ':h')
        if #vim.tbl_keys(groups) > 1 then
          _tail = _tail == '' and tail
            or tail == '' and _tail
            or vim.fs.joinpath(_tail, tail)
        end
        _head = _head == '.' and '' or _head

        if not _groups[_tail] then
          _groups[_tail] = {}
        end
        table.insert(_groups[_tail], { _head, idx })
      end
    end
    groups = _groups
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

return M
