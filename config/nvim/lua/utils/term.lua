local M = {}

---Compiled vim regex that decides if a command is a TUI app
M.TUI_REGEX = vim.regex(
  [[\v^(sudo(\s+--?(\w|-)+((\s+|\=)\S+)?)*\s+)?\S*]]
    .. [[(n?vim?|vimdiff|emacs(client)?|lem|nano|helix|kak|]]
    .. [[tmux|vifm|yazi|ranger|lazygit|h?top|gdb|fzf|nmtui|]]
    .. [[sudoedit|ssh|crontab|asciinema|w3m)]]
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

return M
