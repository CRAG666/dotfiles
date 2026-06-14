local M = {}

---Check if a tab page is empty
---A tab page is considered 'empty' if it has a single empty window
---@param tab integer? default to current tab page
---@return boolean
function M.is_empty(tab)
  tab = tab or vim.api.nvim_get_current_tabpage()
  if not vim.api.nvim_tabpage_is_valid(tab) then
    return true
  end

  local wins = vim.api.nvim_tabpage_list_wins(tab)
  if #wins > 1 then
    return false
  end
  return require('utils.win').is_empty(wins[1])
end

return M
