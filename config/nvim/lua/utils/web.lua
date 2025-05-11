local M = {}

---@param url string
---@param dest? string
---@param on_exit? fun(out: vim.SystemCompleted)
function M.get(url, dest, on_exit)
  dest = dest or vim.fs.basename(dest)

  if vim.fn.executable('curl') == 1 then
    vim.system({ 'curl', url, '-o', dest }, {}, on_exit)
    return
  end

  if vim.fn.executable('wget') == 1 then
    vim.system({ 'wget', url, '-O', dest }, {}, on_exit)
    return
  end

  vim.notify(
    string.format(
      "[utils.web] cannot fetch from '%s': `curl` or `wget` is not executable",
      url
    ),
    vim.log.levels.WARN
  )
end

return M
