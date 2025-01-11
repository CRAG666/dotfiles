local M = {}

---Get string representation of a string with highlight
---@param str? string sign symbol
---@param hl? string name of the highlight group
---@param restore? boolean restore highlight after the sign, default true
---@param force? boolean apply highlight even if 'termguicolors' is off
---@return string sign string representation of the sign with highlight
function M.hl(str, hl, restore, force)
  restore = restore == nil or restore
  -- Don't add highlight in tty to get a cleaner UI
  hl = (vim.go.termguicolors or force) and hl or ''
  return restore and table.concat({ '%#', hl, '#', str or '', '%*' })
    or table.concat({ '%#', hl, '#', str or '' })
end

---Make a winbar string clickable
---@param str string
---@param callback string
---@return string
function M.make_clickable(str, callback)
  return string.format('%%@%s@%s%%X', callback, str)
end

---Escape '%' with '%' in a string to avoid it being treated as a statusline
---field, see `:h 'statusline'`
---@param str string
---@return string
function M.escape(str)
  return (str:gsub('%%', '%%%%'))
end

return M
