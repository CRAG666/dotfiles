local M = {}

M.root_markers = {
  -- Must include python environment root markers here so that we can set cwd
  -- inside a python project and have correct python version in nvim.
  -- This is crucial for running pytest from within nvim using vim-test or
  -- other jobs that requires a python virtual environment.
  { 'venv', 'env', '.venv', '.env' },
  { '.python-version' },
  {
    '.git',
    '.svn',
    '.bzr',
    '.hg',
  },
  {
    '.project',
    '.pro',
    '.sln',
    '.vcxproj',
  },
  {
    'Makefile',
    'makefile',
    'MAKEFILE',
  },
  {
    '.gitignore',
    '.editorconfig',
  },
  {
    'README',
    'README.md',
    'README.txt',
    'README.org',
  },
}

local fs_root = vim.fs.root

---Wrapper of `vim.fs.root()` that accepts layered root markers like
---`vim.lsp.Config.root_markers`
---@param source? integer|string default to current working directory
---@param marker? (string|string[]|string[][]|fun(name: string, path: string): boolean) default to `utils.fs.root_markers`
---@return string?
function M.root(source, marker)
  source = source or 0
  marker = marker or M.root_markers

  if type(marker) ~= 'table' then
    return fs_root(source, marker)
  end

  local joined_markers = {} ---@type string[]

  for _, m in ipairs(marker) do
    -- `m` is a string, join with previous string markers as they are
    -- considered to have the same priority
    if type(m) == 'string' then
      table.insert(joined_markers, m)
      goto continue
    end

    -- `m` is a set of markers of the same priority, search them directly
    -- with `vim.fs.root()`, but before that we have to deal with previous
    -- unresolved marker set
    if not vim.tbl_isempty(joined_markers) then
      local root = fs_root(source, joined_markers)
      joined_markers = {}
      if root then
        return root
      end
    end

    local root = fs_root(source, m)
    if root then
      return root
    end
    ::continue::
  end
end

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
    home = home and vim.fs.normalize(home)
  end
  return vim.fs.normalize(dir) == home
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
