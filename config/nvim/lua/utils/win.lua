local M = {}

---Set window height, without affecting cmdheight
---@param win integer window ID
---@param height integer window height
---@return nil
function M.win_safe_set_height(win, height)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local winnr = vim.fn.winnr()
  if vim.fn.winnr('j') ~= winnr or vim.fn.winnr('k') ~= winnr then
    local cmdheight = vim.go.cmdheight
    vim.api.nvim_win_set_height(win, height)
    vim.go.cmdheight = cmdheight
  end
end

---Get current 'effective' lines (lines can be used by normal windows)
---@return integer
function M.effective_lines()
  local lines = vim.go.lines
  local ch = vim.go.ch
  local ls = vim.go.ls
  return lines
    - ch
    - (
      ls == 0 and 0
      or (ls == 2 or ls == 3) and 1
      or (
        #vim.tbl_filter(function(win)
              return vim.fn.win_gettype(win) ~= 'popup'
            end, vim.api.nvim_tabpage_list_wins(0))
            > 1
          and 1
        or 0
      )
    )
end

---Returns a function to save some attributes over a list of windows
---@param save_method fun(win: integer): any?
---@param store table<integer, any>
---@return fun(wins: integer[]?): nil
function M.save(save_method, store)
  ---@param wins? integer[] list of wins to restore, default to all windows
  return function(wins)
    for _, win in ipairs(wins or vim.api.nvim_list_wins()) do
      local ok, result = pcall(vim.api.nvim_win_call, win, function()
        return save_method(win)
      end)
      if ok then
        store[win] = result
      end
    end
  end
end

---Returns a function to restore the attributes of windows from `store`
---@param restore_method fun(win: integer, data: any): any?
---@param store table<integer, any>
---@return fun(wins: integer[]?): nil
function M.rest(restore_method, store)
  ---@param wins? integer[] list of wins to restore, default to all windows
  return function(wins)
    if not store then
      return
    end
    for _, win in pairs(wins or vim.api.nvim_list_wins()) do
      if store[win] then
        if not vim.api.nvim_win_is_valid(win) then
          store[win] = nil
        else
          pcall(vim.api.nvim_win_call, win, function()
            restore_method(win, store[win])
          end)
        end
      end
    end
  end
end

---Returns a function to clear the attributes of all windows in `store`
---@param store table<integer, any>
---@return fun(): nil
function M.clear(store)
  return function()
    for win, _ in pairs(store) do
      store[win] = nil
    end
  end
end

local views = {}
local ratios = {}
local heights = {}

vim.api.nvim_create_autocmd('WinClosed', {
  desc = 'Clear window data when window is closed.',
  group = vim.api.nvim_create_augroup('WinUtilsClearData', {}),
  callback = function(info)
    local win = tonumber(info.match)
    if win then
      views[win] = nil
      ratios[win] = nil
      heights[win] = nil
    end
  end,
})

M.clearviews = M.clear(views)
M.clearratio = M.clear(ratios)
M.clearheights = M.clear(heights)

-- stylua: ignore start
M.saveviews = M.save(function(_) return vim.fn.winsaveview() end, views)
M.restviews = M.rest(function(_, view) vim.fn.winrestview(view) end, views)
M.saveheights = M.save(vim.api.nvim_win_get_height, heights)
M.restheights = M.rest(M.win_safe_set_height, heights)
-- stylua: ignore end

---Save window ratios as { height_ratio, width_ratio } tuple
M.saveratio = M.save(function(win)
  local h = vim.api.nvim_win_get_height(win)
  local w = vim.api.nvim_win_get_width(win)
  return {
    hr = h / M.effective_lines(),
    wr = w / vim.go.columns,
    h = h,
    w = w,
  }
end, ratios)

---Restore window ratios, respect &winfixheight and &winfixwidth and keep
---command window height untouched
M.restratio = M.rest(function(win, ratio)
  local hr = type(ratio.hr) == 'table' and ratio.hr[vim.val_idx] or ratio.hr
  local wr = type(ratio.wr) == 'table' and ratio.wr[vim.val_idx] or ratio.wr
  local h = ratio.h
  local w = ratio.w
  local cmdwin = vim.fn.win_gettype() == 'command'

  if not vim.wo.wfh and not cmdwin then
    M.win_safe_set_height(win, vim.fn.round(M.effective_lines() * hr))
  else
    vim.schedule(function()
      M.win_safe_set_height(win, h)
    end)
  end
  if not vim.wo.wfw and not cmdwin then
    vim.api.nvim_win_set_width(win, vim.fn.round(vim.go.columns * wr))
  else
    vim.schedule(function()
      vim.api.nvim_win_set_width(win, w)
    end)
  end
end, ratios)

---Check if a window is empty
---A window is considered 'empty' if its containing buffer is empty
---@param win integer? default to current window
---@return boolean
function M.is_empty(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return true
  end
  return require('utils.buf').is_empty(vim.api.nvim_win_get_buf(win))
end

return M
