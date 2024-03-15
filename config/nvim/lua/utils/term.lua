local M = {}

---List of programs considered as TUI apps
M.tui = {
  vi = true,
  fzf = true,
  nvi = true,
  kak = true,
  vim = true,
  nvim = true,
  sudo = true,
  nano = true,
  helix = true,
  nmtui = true,
  emacs = true,
  vimdiff = true,
  lazygit = true,
  sudoedit = true,
  emacsclient = true,
}

---Check if any of the processes in terminal buffer `buf` is a TUI app
---@param buf integer? buffer handler
---@return boolean?
function M.running_tui(buf)
  local proc_names = M.proc_names(buf)
  for _, proc_name in ipairs(proc_names) do
    if M.tui[proc_name] then
      return true
    end
  end
end

---Get list of names of the processes running in the terminal
---@param buf integer? terminal buffer handler, default to 0 (current)
---@return string[]: process names
function M.proc_names(buf)
  buf = buf or 0
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].bt ~= "terminal" then
    return {}
  end
  local channel = vim.bo[buf].channel
  local chan_valid, pid = pcall(vim.fn.jobpid, channel)
  if not chan_valid then
    return {}
  end
  return vim.split(vim.fn.system("ps h -o comm -g " .. pid), "\n", {
    trimempty = true,
  })
end

return M
