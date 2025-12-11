local M = {}

vim.api.nvim_create_autocmd({ 'BufWrite', 'FileChangedShellPost' }, {
  group = vim.api.nvim_create_augroup('my.git.refresh_writetick', {}),
  callback = function(args)
    vim.b[args.buf].git_writetick = vim.uv.hrtime()
  end,
})

---@class git.diffstat
---@field add? integer
---@field removed? integer
---@field changed? integer

---Get the diff stats for the current buffer asynchronously
---@param buf integer? buffer handler, defaults to the current buffer
---@param args string[]? arguments passed to `git` command
---@return git.diffstat? # diff stats
function M.diffstat(buf, args)
  buf = vim._resolve_bufnr(buf or 0)
  if not vim.api.nvim_buf_is_valid(buf) then
    return {}
  end

  if
    (vim.b[buf].git_diffstat_writetick or 0)
      < (vim.b[buf].git_writetick or 1)
    and vim.fn.executable('git') == 1
  then
    local bufname = vim.api.nvim_buf_get_name(buf)
    local dirname = vim.fs.dirname(bufname)
    local now = vim.uv.hrtime()
    local cmd = vim.list_extend({ 'git', '-C', dirname, unpack(args or {}) }, {
      '--no-pager',
      'diff',
      '-U0',
      '--no-color',
      '--no-ext-diff',
      '--',
      bufname,
    })

    ---Parse git diff output and save it in buf-local variables
    ---@param o vim.SystemCompleted
    local function handler(o)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local stat = { added = 0, removed = 0, changed = 0 }
      for _, line in ipairs(vim.split(o.stdout, '\n')) do
        if line:find('^@@ ') then
          local num_lines_old, num_lines_new =
            line:match('^@@ %-%d+,?(%d*) %+%d+,?(%d*)')
          num_lines_old = tonumber(num_lines_old) or 1
          num_lines_new = tonumber(num_lines_new) or 1
          local num_lines_changed = math.min(num_lines_old, num_lines_new)
          stat.changed = stat.changed + num_lines_changed
          if num_lines_old > num_lines_new then
            stat.removed = stat.removed + num_lines_old - num_lines_changed
          else
            stat.added = stat.added + num_lines_new - num_lines_changed
          end
        end
      end

      if (vim.b[buf].git_diffstat_writetick or 0) < now then
        vim.b[buf].git_diffstat = o.code == 0 and stat or nil
        vim.b[buf].git_diffstat_writetick = now
      end
    end

    if vim.b[buf].git_diffstat_writetick then
      vim.system(cmd, {}, vim.schedule_wrap(handler))
    else
      handler(vim.system(cmd):wait())
    end
  end

  return vim.b[buf].git_diffstat
end

---Asynchronously execute git command and get output
---NOTE: output can be out of date
---@param buf integer? buffer handler, defaults to the current buffer
---@param args string[] arguments passed to `git` command
---@return string?
function M.execute(buf, args)
  buf = vim._resolve_bufnr(buf or 0)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local cache_key = vim.fn.sha256(table.concat(args)):sub(1, 8)
  local cache_key_writetick = cache_key .. '_writetick'

  if
    (vim.b[buf][cache_key_writetick] or 0) < (vim.b[buf].git_writetick or 1)
    and vim.fn.executable('git') == 1
  then
    local now = vim.uv.hrtime()
    local cmd = {
      'git',
      '-C',
      vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
      unpack(args),
    }

    ---Extract git command output in stdout and save it in buf-local variables
    ---@param o vim.SystemCompleted
    local function handler(o)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      if (vim.b[buf][cache_key_writetick] or 0) < now then
        vim.b[buf][cache_key] = o.code == 0 and vim.trim(o.stdout) or nil
        vim.b[buf][cache_key_writetick] = now
      end
    end

    if vim.b[buf][cache_key_writetick] then
      vim.system(cmd, {}, vim.schedule_wrap(handler))
    else
      handler(vim.system(cmd):wait())
    end
  end

  return vim.b[buf][cache_key]
end

---Get buffer's current work tree and git dir with fallback
---@param buf integer? buffer handler, default to current buffer
---@param fallback_args string[][] alternative git arguments to try
---@return string? work_tree
---@return string? git_dir
function M.resolve_context(buf, fallback_args)
  buf = vim._resolve_bufnr(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local work_tree = M.execute(buf, { 'rev-parse', '--show-toplevel' })
  for _, args in ipairs(fallback_args) do
    if work_tree then
      break
    end
    work_tree = M.execute(
      buf,
      vim.list_extend(vim.deepcopy(args), { 'rev-parse', '--show-toplevel' })
    )
  end

  local git_dir = M.execute(buf, { 'rev-parse', '--git-dir' })
  for _, args in ipairs(fallback_args) do
    if git_dir then
      break
    end
    git_dir = M.execute(
      buf,
      vim.list_extend(vim.deepcopy(args), { 'rev-parse', '--git-dir' })
    )
  end

  return work_tree, git_dir
end

return M
