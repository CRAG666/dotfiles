local M = {}
local utils = require('utils')

---Read json contents as lua table
---@param path string
---@param opts table? same option table as `vim.json.decode()`
---@return table
function M.read(path, opts)
  opts = opts or {}
  local str = utils.fs.read_file(path)
  local ok, tbl = pcall(vim.json.decode, str, opts)
  return ok and tbl or {}
end

---Write json contents
---@param path string
---@param tbl table
---@return boolean success
function M.write(path, tbl)
  local ok, str = pcall(vim.json.encode, tbl)
  if not ok then
    return false
  end
  return utils.fs.write_file(path, str)
end

return M
