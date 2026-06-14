local M = {}

---Set window height, without affecting cmdheight
---@param win integer window ID
---@param height integer window height
---@return nil
function M.win_safe_set_height(win, height)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local win_above = vim.api.nvim_win_call(win, function()
    return vim.fn.win_getid(vim.fn.winnr('j'))
  end)
  local win_below = vim.api.nvim_win_call(win, function()
    return vim.fn.win_getid(vim.fn.winnr('k'))
  end)
  if win_above == win and win_below == win then
    return
  end

  local ch = vim.go.cmdheight
  vim.api.nvim_win_set_height(win, height)
  vim.go.cmdheight = ch
end

---Returns a function to save some attributes over a list of windows
---@param save_method fun(win: integer): any?
---@return fun(store: table<integer, any>, wins: integer[]?)
function M.save(save_method)
  ---@param store string|table<integer, any>
  ---@param wins? integer[] list of wins to restore, default to all windows in
  ---current tabpage
  return function(store, wins)
    if type(store) == 'string' then
      store = _G[store]
    end
    if not store then
      return
    end
    for _, win in ipairs(wins or vim.api.nvim_tabpage_list_wins(0)) do
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
---@return fun(store: table<integer, any>, wins: integer[]?)
function M.restore(restore_method)
  ---@param store string|table<integer, any>
  ---@param wins? integer[] list of wins to restore, default to all windows in
  ---current tabpage
  return function(store, wins)
    if type(store) == 'string' then
      store = _G[store]
    end
    if not store then
      return
    end

    for _, win in pairs(wins or vim.api.nvim_tabpage_list_wins(0)) do
      if not store[win] then
        goto continue
      end
      if not vim.api.nvim_win_is_valid(win) then
        store[win] = nil
        goto continue
      end

      pcall(vim.api.nvim_win_call, win, function()
        restore_method(win, store[win])
      end)
      ::continue::
    end
  end
end

M.save_views = M.save(function(_)
  return vim.fn.winsaveview()
end)

M.restore_views = M.restore(function(_, view)
  vim.fn.winrestview(view)
end)

M.save_heights = M.save(vim.api.nvim_win_get_height)
M.restore_heights = M.restore(M.win_safe_set_height)

M.save_widths = M.save(vim.api.nvim_win_get_width)
M.restore_widths = M.restore(vim.api.nvim_win_set_width)

---Save window ratios as { height_ratio, width_ratio } tuple
M.save_ratio = M.save(function(win)
  return {
    h = { vim.api.nvim_win_get_height(win), vim.go.lines }, -- window height, vim height
    w = { vim.api.nvim_win_get_width(win), vim.go.columns }, -- window width, vim width
  }
end)

---Restore window ratios, respect &winfixheight and &winfixwidth and keep
---command window height untouched
M.restore_ratio = M.restore(function(win, ratio)
  local h, vim_h = ratio.h[1], ratio.h[2]
  local w, vim_w = ratio.w[1], ratio.w[2]

  if vim.fn.win_gettype(win) == '' then
    M.win_safe_set_height(win, vim.fn.round(vim.go.lines * h / vim_h))
    vim.api.nvim_win_set_width(win, vim.fn.round(vim.go.columns * w / vim_w))
    return
  end

  -- Special window, set to original height & width instead of ratio
  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(win) then
      return
    end
    M.win_safe_set_height(win, h)
    vim.api.nvim_win_set_width(win, w)
  end)
end)

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
