local M = {}

---Returns whether the cursor is in a math zone
---@return boolean
function M.in_mathzone()
  return vim.g.loaded_vimtex == 1
    and vim.api.nvim_eval('vimtex#syntax#in_mathzone()') == 1
end

---Returns whether the cursor is in normal zone (not in math zone)
---@return boolean
function M.in_normalzone()
  return not M.in_mathzone()
end

return M
