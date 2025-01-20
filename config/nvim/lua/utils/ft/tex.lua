local M = {}

---Returns whether the cursor is in a math zone
---@return boolean
function M.in_mathzone()
  return vim.b.vimtex_id ~= nil
    and vim.F.npcall(vim.api.nvim_eval, 'vimtex#syntax#in_mathzone()') == 1
end

---Returns whether the cursor is in normal zone (not in math zone)
---@return boolean
function M.in_normalzone()
  return not M.in_mathzone()
end

return M
