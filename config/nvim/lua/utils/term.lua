local M = {}

---Compiled vim regex that decides if a command is a TUI app
M.TUI_REGEX = vim.regex(
  [[\v^(sudo(\s+--?(\w|-)+((\s+|\=)\S+)?)*\s+)?\S*]]
    .. [[(n?vim?|vimdiff|emacs(client)?|lem|nano|helix|kak|]]
    .. [[tmux|vifm|yazi|ranger|lazygit|h?top|gdb|fzf|nmtui|]]
    .. [[sudoedit|crontab|asciinema|w3m)]]
)

---Check if any of the processes in terminal buffer `buf` is a TUI app
---@param buf integer? buffer handler
---@return boolean?
function M.running_tui(buf)
  local cmds = M.fg_cmds(buf)
  for _, cmd in ipairs(cmds) do
    if M.TUI_REGEX:match_str(cmd) then
      return true
    end
  end
  return false
end

---Get the command running in the foreground in the terminal buffer 'buf'
---@param buf integer? terminal buffer handler, default to 0 (current)
---@return string[]: command running in the foreground
function M.fg_cmds(buf)
  buf = buf or 0
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].bt ~= 'terminal' then
    return {}
  end
  local channel = vim.bo[buf].channel
  local chan_valid, pid = pcall(vim.fn.jobpid, channel)
  if not chan_valid then
    return {}
  end

  local cmds = {}
  for stat_cmd_str in
    vim.gsplit(
      vim
        .system({ 'ps', 'h', '-o', 'stat,args', '-g', tostring(pid) })
        :wait().stdout,
      '\n',
      { trimempty = true }
    )
  do
    local stat, cmd = stat_cmd_str:match('(%S+)%s+(.*)')
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
    'term://%s//%s:%s%s',
    vim.fn
      .fnamemodify(opts.path or path or vim.fn.getcwd(), ':~')
      :gsub('/+$', ''),
    opts.pid or pid or '',
    opts.cmd or cmd or '',
    (function()
      local name_str = opts.name or name
      return name_str == '' and '' or ' # ' .. name_str
    end)()
  )
end

local bracket_paste_start = '\27[200~'
local bracket_paste_end = '\27[201~'

---Send multi-line message to terminal
---@param msg string|string[] message
---@param buf? integer terminal buffer, default to current buffer
function M.send(msg, buf)
  buf = buf or vim.api.nvim_get_current_buf()
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
    bracket_paste_start .. table.concat(msg, '\n') .. bracket_paste_end
  )
end

return M
