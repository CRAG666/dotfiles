local M = {}

---Compiled vim regex that decides if a command is a TUI app
M.TUI_REGEX = vim.regex(
  [[\v(sudo.*\s+)?(.*sh\s+-c\s+)?(.*python.*)?\S*]]
    .. [[(n?vim?|vimdiff|emacs(client)?|lem|nano|h(eli)?x|kak|]]
    .. [[tmux|vifm|yazi|ranger|lazygit|h?top|gdb|fzf|nmtui|opencode|]]
    .. [[sudoedit|crontab|asciinema|w3m|python3?\s+-m|ssh)($|\s+)]]
)

---Check if any of the processes in terminal buffer `buf` is a TUI app
---@param buf integer? buffer handler
---@return boolean?
function M.running_tui(buf)
  return M.running(M.TUI_REGEX, buf)
end

---Check if terminal buffer is running a specific command
---@param regex vim.regex regex of command
---@param buf? integer buffer handler
---@return boolean
function M.running(regex, buf)
  local cmds = M.fg_cmds(buf)
  for _, cmd in ipairs(cmds) do
    if regex:match_str(cmd) then
      return true
    end
  end
  return false
end

---Get the command running in the foreground in the terminal buffer 'buf'
---@param buf integer? terminal buffer handler, default to 0 (current)
---@return string[]: command running in the foreground
function M.fg_cmds(buf)
  buf = vim._resolve_bufnr(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].bt ~= 'terminal' then
    return {}
  end
  local channel = vim.bo[buf].channel
  local chan_valid, pid = pcall(vim.fn.jobpid, channel)
  if not chan_valid then
    return {}
  end

  local tty = (function()
    local obj = vim.system({ 'ps', '-o', 'tty=', '-p', tostring(pid) }):wait()
    if obj.code == 0 then
      return vim.trim(obj.stdout)
    end
  end)()
  if not tty or tty == '' then
    return {}
  end

  local stat_cmds_str = (function()
    local obj = vim.system({ 'ps', '-o', 'stat=,args=', '-t', tty }):wait()
    if obj.code == 0 then
      return obj.stdout
    end
  end)()
  if not stat_cmds_str then
    return {}
  end

  local cmds = {}
  for line in vim.gsplit(stat_cmds_str, '\n', { trimempty = true }) do
    local stat, cmd = line:match('(%S+)%s+(.*)')
    if stat and stat:find('^%S+%+') then
      table.insert(cmds, cmd)
    end
  end

  return cmds
end

---@param bufname string
---@return string path
---@return string pid
---@return string cmd
---@return string name
function M.parse_name(bufname)
  local path, pid, cmd, name =
    bufname:match('^term://(.*)//(%d+):([^#]*)%s*#?%s*(.*)')
  return vim.fn.fnamemodify(vim.trim(path or ''), ':p'),
    vim.trim(pid or ''),
    vim.trim(cmd or ''),
    vim.trim(name or '')
end

---@param bufname string original terminal buffer name
---@param opts? { path?: string, pid?: string|integer, cmd?: string, name?: string }
---@return string
function M.compose_name(bufname, opts)
  if
    not opts
    or not opts.path and not opts.pid and not opts.cmd and not opts.name
  then
    return bufname
  end

  local path, pid, cmd, name = M.parse_name(bufname)
  return string.format(
    'term://%s//%s%s%s',
    vim.fn
      .fnamemodify(opts.path or path or vim.fn.getcwd(), ':~')
      :gsub('/+$', ''),
    (function()
      local term_pid = opts.pid or pid or ''
      return tonumber(term_pid) and term_pid .. ':' or ''
    end)(),
    opts.cmd or cmd or '',
    (function()
      local name_str = opts.name or name
      return name_str == '' and '' or ' # ' .. name_str
    end)()
  )
end

M.BRACKET_PASTE_START = '\27[200~'
M.BRACKET_PASTE_END = '\27[201~'

---Send multi-line message to terminal
---@param msg string|string[] message
---@param buf? integer terminal buffer, default to current buffer
function M.send(msg, buf)
  buf = vim._resolve_bufnr(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].bt ~= 'terminal' then
    return
  end

  local chan = vim.b[buf].terminal_job_id
  if not chan or vim.tbl_isempty(vim.api.nvim_get_chan_info(chan)) then
    return
  end

  if type(msg) ~= 'table' then
    msg = { msg }
  end
  if vim.tbl_isempty(msg) then
    return
  end

  vim.api.nvim_chan_send(
    chan,
    M.BRACKET_PASTE_START .. table.concat(msg, '\n') .. M.BRACKET_PASTE_END
  )
end

return M
