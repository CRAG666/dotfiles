_G._winbar = {}
local hlgroups = require('ui.winbar.hlgroups')
local bar = require('ui.winbar.bar')
local configs = require('ui.winbar.configs')
local utils = require('ui.winbar.utils')

---Store the on_click callbacks for each winbar symbol
---Make it assessable from global only because nvim's viml-lua interface
---(v:lua) only support calling global lua functions
---@type table<string, table<string, function>>
---@see winbar_t:update
_G._winbar.callbacks = setmetatable({}, {
  __index = function(self, buf)
    self[buf] = setmetatable({}, {
      __index = function(this, win)
        this[win] = {}
        return this[win]
      end,
    })
    return self[buf]
  end,
})

---@type table<integer, table<integer, winbar_t>>
_G._winbar.bars = setmetatable({}, {
  __index = function(self, buf)
    self[buf] = setmetatable({}, {
      __index = function(this, win)
        this[win] = bar.winbar_t:new({
          sources = configs.eval(configs.opts.bar.sources, buf, win),
        })
        return this[win]
      end,
    })
    return self[buf]
  end,
})

---Get winbar string for current window
---@return string
function _G._winbar.get_winbar()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  return tostring(_G._winbar.bars[buf][win])
end

---Setup winbar
---@param opts winbar_configs_t?
local function setup(opts)
  configs.set(opts)
  hlgroups.init()
  local groupid = vim.api.nvim_create_augroup('WinBar', {})
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    utils.bar.attach(vim.api.nvim_win_get_buf(win), win)
  end
  if not vim.tbl_isempty(configs.opts.general.attach_events) then
    vim.api.nvim_create_autocmd(configs.opts.general.attach_events, {
      group = groupid,
      callback = function(info)
        -- Try attaching winbar to all windows containing the buffer
        -- Notice that we cannot simply let `win=0` here since the current
        -- buffer isn't necessarily the window containing the buffer
        for _, win in ipairs(vim.fn.win_findbuf(info.buf)) do
          utils.bar.attach(info.buf, win)
        end
      end,
      desc = 'Attach winbar',
    })
  end
  vim.api.nvim_create_autocmd('BufDelete', {
    group = groupid,
    callback = function(info)
      utils.bar.exec('del', { buf = info.buf })
      _G._winbar.bars[info.buf] = nil
      _G._winbar.callbacks['buf' .. info.buf] = nil
    end,
    desc = 'Remove winbar from cache on buffer wipeout.',
  })
  if not vim.tbl_isempty(configs.opts.general.update_events.win) then
    vim.api.nvim_create_autocmd(configs.opts.general.update_events.win, {
      group = groupid,
      callback = function(info)
        if info.event == 'WinResized' then
          for _, win in ipairs(vim.v.event.windows or {}) do
            utils.bar.exec('update', { win = win })
          end
        else
          utils.bar.exec('update', {
            win = info.event == 'WinScrolled' and tonumber(info.match)
              or vim.api.nvim_get_current_win(),
          })
        end
      end,
      desc = 'Update a single winbar.',
    })
  end
  if not vim.tbl_isempty(configs.opts.general.update_events.buf) then
    vim.api.nvim_create_autocmd(configs.opts.general.update_events.buf, {
      group = groupid,
      callback = function(info)
        utils.bar.exec('update', { buf = info.buf })
      end,
      desc = 'Update all winbars associated with buf.',
    })
  end
  if not vim.tbl_isempty(configs.opts.general.update_events.global) then
    vim.api.nvim_create_autocmd(configs.opts.general.update_events.global, {
      group = groupid,
      callback = function(info)
        if vim.tbl_isempty(utils.bar.get({ buf = info.buf })) then
          return
        end
        utils.bar.exec('update')
      end,
      desc = 'Update all winbars.',
    })
  end
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    group = groupid,
    callback = function(info)
      utils.bar.exec('del', { win = tonumber(info.match) })
    end,
    desc = 'Remove winbar from cache on window closed.',
  })
  if configs.opts.bar.hover then
    vim.on_key(function(key)
      if key == vim.keycode('<MouseMove>') then
        utils.bar.update_hover_hl(vim.fn.getmousepos())
      end
    end)
    vim.api.nvim_create_autocmd('FocusLost', {
      group = groupid,
      callback = function()
        utils.bar.update_hover_hl({})
      end,
      desc = 'Remove hover highlight on focus lost.',
    })
    vim.api.nvim_create_autocmd('FocusGained', {
      group = groupid,
      callback = function()
        utils.bar.update_hover_hl(vim.fn.getmousepos())
      end,
      desc = 'Update hover highlight on focus gained.',
    })
  end
  vim.g.loaded_winbar = true
end

return {
  setup = setup,
}
