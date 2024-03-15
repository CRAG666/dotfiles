local M = {}

---Print git command error
---@param cmd string[] shell command
---@param msg string error message
---@param lev number? log level to use for errors, defaults to WARN
---@return nil
function M.error(cmd, msg, lev)
  lev = lev or vim.log.levels.WARN
  vim.notify(
    '[git] failed to execute git command: '
      .. table.concat(cmd, ' ')
      .. '\n'
      .. msg,
    lev
  )
end

---Execute git command in given directory synchronously
---@param path string
---@param cmd string[] git command to execute
---@param error_lev number? log level to use for errors, hide errors if nil or false
---@reurn { success: boolean, output: string }
function M.dir_execute(path, cmd, error_lev)
  local shell_args = { 'git', '-C', path, unpack(cmd) }
  local shell_out = vim.fn.system(shell_args)
  if vim.v.shell_error ~= 0 then
    if error_lev then
      M.error(shell_args, shell_out, error_lev)
    end
    return {
      success = false,
      output = shell_out,
    }
  end
  return {
    success = true,
    output = shell_out,
  }
end

---Execute git command in current directory synchronously
---@param cmd string[] git command to execute
---@param error_lev number? log level to use for errors, hide errors if nil or false
---@return { success: boolean, output: string }
function M.execute(cmd, error_lev)
  local shell_args = { 'git', unpack(cmd) }
  local shell_out = vim.fn.system(shell_args)
  if vim.v.shell_error ~= 0 then
    if error_lev then
      M.error(shell_args, shell_out, error_lev)
    end
    return {
      success = false,
      output = shell_out,
    }
  end
  return {
    success = true,
    output = shell_out,
  }
end

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = vim.api.nvim_create_augroup('RefreshGitBranchCache', {}),
  callback = function(info)
    vim.b[info.buf].git_branch = nil
  end,
})

---Get the current branch name asynchronously
---@param buf integer? defaults to the current buffer
---@return string branch name
function M.branch(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return ''
  end

  local branch = vim.b[buf].git_branch
  if branch then
    return branch
  end

  vim.b[buf].git_branch = ''
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  if dir then
    pcall(
      vim.system,
      { 'git', '-C', dir, 'rev-parse', '--abbrev-ref', 'HEAD' },
      { stderr = false },
      function(err)
        local buf_branch = err.stdout:gsub('\n.*', '')
        pcall(vim.api.nvim_buf_set_var, buf, 'git_branch', buf_branch)
      end
    )
  end
  return vim.b[buf].git_branch
end

vim.api.nvim_create_autocmd({ 'BufWrite', 'FileChangedShellPost' }, {
  group = vim.api.nvim_create_augroup('RefreshGitDiffCache', {}),
  callback = function(info)
    vim.b[info.buf].git_diffstat = nil
  end,
})

---Get the diff stats for the current buffer asynchronously
---@param buf integer? buffer handler, defaults to the current buffer
---@return {added: integer?, removed: integer?, changed: integer?} diff stats
function M.diffstat(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return {}
  end

  if vim.b[buf].git_diffstat then
    return vim.b[buf].git_diffstat
  end

  vim.b[buf].git_diffstat = {}
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  local dir = vim.fs.dirname(path)
  if dir and M.branch(buf):find('%S') then
    pcall(vim.system, {
      'git',
      '-C',
      dir,
      '--no-pager',
      'diff',
      '-U0',
      '--no-color',
      '--no-ext-diff',
      '--',
      path,
    }, { stderr = false }, function(err)
      local stat = { added = 0, removed = 0, changed = 0 }
      for _, line in ipairs(vim.split(err.stdout, '\n')) do
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
      pcall(vim.api.nvm_buf_set_var, buf, 'git_diffstat', stat)
    end)
  end
  return vim.b[buf].git_diffstat
end

return M
