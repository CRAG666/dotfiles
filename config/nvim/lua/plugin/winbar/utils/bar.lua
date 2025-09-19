local M = {}

---Get winbar
--- - If only `opts.win` is specified, return the winbar attached the window;
--- - If only `opts.buf` is specified, return all winbars attached the buffer;
--- - If both `opts.win` and `opts.buf` are specified, return the winbar attached
---   the window that contains the buffer;
--- - If neither `opts.win` nor `opts.buf` is specified, return all winbars
---   in the form of `table<buf, table<win, winbar_t>>`
---@param opts {win: integer?, buf: integer?}?
---@return (winbar_t?)|table<integer, winbar_t>|table<integer, table<integer, winbar_t>>
function M.get(opts)
  opts = opts or {}
  if opts.buf then
    if opts.win then
      return rawget(_G._winbar.bars, opts.buf)
        and rawget(_G._winbar.bars[opts.buf], opts.win)
    end
    return rawget(_G._winbar.bars, opts.buf) or {}
  end
  if opts.win then
    if not vim.api.nvim_win_is_valid(opts.win) then
      return
    end
    local buf = vim.api.nvim_win_get_buf(opts.win)
    return rawget(_G._winbar.bars, buf)
      and rawget(_G._winbar.bars[buf], opts.win)
  end
  return _G._winbar.bars
end

---Get current winbar
---@return winbar_t?
function M.get_current()
  return M.get({ win = vim.api.nvim_get_current_win() })
end

---Call method on winbar(s) given the window id and/or buffer number the
---winbar(s) attached to
--- - If only `opts.win` is specified, call the winbar attached the window;
--- - If only `opts.buf` is specified, call all winbars attached the buffer;
--- - If both `opts.win` and `opts.buf` are specified, call the winbar attached
---   the window that contains the buffer;
--- - If neither `opts.win` nor `opts.buf` is specified, call all winbars
--- - `opts.params` specifies params passed to the method
---@param method string
---@param opts {win: integer?, buf: integer?, params: table?}?
---@return any?: return values of the method
function M.exec(method, opts)
  opts = opts or {}
  opts.params = opts.params or {}
  local winbars = M.get(opts)
  if not winbars or vim.tbl_isempty(_G._winbar) then
    return
  end
  if opts.win then
    return winbars[method](winbars, unpack(opts.params))
  end
  if opts.buf then
    local results = {}
    for _, winbar in pairs(winbars) do
      table.insert(results, {
        winbar[method](winbar, unpack(opts.params)),
      })
    end
    return results
  end
  local results = {}
  for _, buf_winbars in pairs(winbars) do
    for _, winbar in pairs(buf_winbars) do
      table.insert(results, {
        winbar[method](winbar, unpack(opts.params)),
      })
    end
  end
  return results
end

---@type winbar_t?
local last_hovered_winbar = nil

---Update winbar hover highlights given the mouse position
---@param mouse table
---@return nil
function M.update_hover_hl(mouse)
  local winbar = M.get({ win = mouse.winid })
  if not winbar or mouse.winrow ~= 1 or mouse.line ~= 0 then
    if last_hovered_winbar then
      last_hovered_winbar:update_hover_hl()
      last_hovered_winbar = nil
    end
    return
  end
  if last_hovered_winbar and last_hovered_winbar ~= winbar then
    last_hovered_winbar:update_hover_hl()
  end
  winbar:update_hover_hl(math.max(0, mouse.wincol - 1))
  last_hovered_winbar = winbar
end

---Attach winbar to window
---@param buf integer
---@param win integer
---@return nil
function M.attach(buf, win)
  local configs = require('plugin.winbar.configs')
  if configs.eval(configs.opts.bar.enable, buf, win) then
    vim.wo[win][0].winbar = '%{%v:lua._winbar()%}'
  end
end

---Set min widths for dropbar symbols
---@param symbols winbar_symbol_t[]
---@param min_widths integer[]
function M.set_min_widths(symbols, min_widths)
  for i, w in ipairs(min_widths) do
    if i > #symbols then
      break
    end
    symbols[#symbols - i + 1].min_width = w
  end
end

return M
