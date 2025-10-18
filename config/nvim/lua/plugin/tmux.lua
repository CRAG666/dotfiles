---@alias direction.nvim 'h'|'j'|'k'|'l'
---@alias direction.tmux 'L'|'D'|'U'|'R'
---@alias direction.tmux_borderpane 'left'|'bottom'|'top'|'right'

---@return string tmux socket path
local function tmux_get_socket()
  return vim.split(vim.env.TMUX, ',')[1]
end

---@param command string tmux command to execute
---@param global boolean? command should be executed globally instead of in current pane
---@return string tmux command output
local function tmux_exec(command, global)
  command = global and string.format('tmux %s', command)
    or string.format('tmux -S %s %s', tmux_get_socket(), command)
  local handle = assert(
    io.popen(command),
    string.format('[tmux-nav]: unable to execute: [%s]', command)
  )
  local result = handle:read('*a')
  handle:close()
  return result
end

---Get tmux option value in current pane
---@param opt string tmux pane option
---@return string tmux pane option value
local function tmux_get_pane_opt(opt)
  return (
    tmux_exec(
      string.format(
        "display-message -pt %s '#{%s}'",
        vim.env.TMUX_PANE,
        vim.fn.escape(opt, "'\\")
      )
    ):gsub('\n.*', '')
  )
end

---Set tmux option value in current pane
---@param opt string tmux pane option
---@param val string tmux pane option value
---@return nil
local function tmux_set_pane_opt(opt, val)
  tmux_exec(
    string.format(
      "set -pt %s %s '%s'",
      vim.env.TMUX_PANE,
      opt,
      vim.fn.escape(val, "'\\")
    )
  )
end

---Unset a tmux pane option
---@param opt string tmux pane option
---@return nil
local function tmux_unset_pane_opt(opt)
  tmux_exec(
    string.format(
      "set -put %s '%s'",
      vim.env.TMUX_PANE,
      vim.fn.escape(opt, "'\\")
    )
  )
end

---@return boolean
local function tmux_is_zoomed()
  return tmux_get_pane_opt('window_zoomed_flag') == '1'
end

---@type table<direction.nvim, direction.tmux_borderpane>
local tmux_pane_position_map = {
  h = 'left',
  j = 'bottom',
  k = 'top',
  l = 'right',
}

---@param direction direction.nvim
---@return boolean
local function tmux_at_border(direction)
  return tmux_get_pane_opt('pane_at_' .. tmux_pane_position_map[direction])
    == '1'
end

---@param direction direction.nvim
---@return boolean
local function tmux_should_move(direction)
  return not tmux_is_zoomed() and not tmux_at_border(direction)
end

---@type table<direction.nvim, direction.tmux>
local tmux_direction_map = {
  h = 'L',
  j = 'D',
  k = 'U',
  l = 'R',
}

---@param direction direction.nvim
---@param count integer? default to 1
---@return nil
local function tmux_navigate(direction, count)
  count = count or 1
  for _ = 1, count do
    tmux_exec(
      string.format(
        "select-pane -t '%s' -%s",
        vim.env.TMUX_PANE,
        tmux_direction_map[direction]
      )
    )
  end
end

---@param direction direction.nvim
---@return boolean
local function nvim_at_border(direction)
  return vim.fn.winnr() == vim.fn.winnr(direction)
end

---@return boolean
local function nvim_in_floating_win()
  return vim.fn.win_gettype() == 'popup'
end

---Check if nvim has only one window in current session
---@return boolean
local function nvim_has_only_win()
  return #vim
    .iter(vim.api.nvim_list_wins())
    :filter(function(win)
      return vim.fn.win_gettype(win) ~= 'popup'
    end)
    :totable() <= 1
end

---Check if nvim has only one window in current tab
---@return boolean
local function nvim_tabpage_has_only_win()
  return #vim
    .iter(vim.api.nvim_tabpage_list_wins(0))
    :filter(function(win)
      return vim.fn.win_gettype(win) ~= 'popup'
    end)
    :totable() <= 1
end

---@param direction direction.nvim
---@param count integer? default to 1
---@return nil
local function nvim_navigate(direction, count)
  vim.cmd.wincmd({
    direction,
    count = count,
  })
end

---@param direction direction.nvim
---@param count integer? default to 1
---@return nil
local function navigate(direction, count)
  count = count or 1
  if
    (nvim_at_border(direction) or nvim_in_floating_win())
    and tmux_should_move(direction)
  then
    tmux_navigate(direction, count)
  else
    nvim_navigate(direction, count)
  end
end

---@param direction direction.nvim
---@return function: rhs of a window navigation keymap
local function navigate_wrap(direction)
  return function()
    navigate(direction, vim.v.count1)
  end
end

---@return boolean
local function tmux_mapkey_default_condition()
  return not tmux_is_zoomed() and nvim_tabpage_has_only_win()
end

---@return boolean
local function tmux_mapkey_close_win_condition()
  return not tmux_is_zoomed()
    and not nvim_in_floating_win()
    and nvim_has_only_win()
end

---@return boolean
local function tmux_mapkey_resize_pane_horiz_condition()
  return not tmux_is_zoomed() and nvim_at_border('l') and nvim_at_border('h')
end

---@return boolean
local function tmux_mapkey_resize_pane_vert_condition()
  return not tmux_is_zoomed() and nvim_at_border('j') and nvim_at_border('k')
end

---@return fun(): boolean
local function tmux_mapkey_navigate_condition(direction)
  return function()
    return (nvim_at_border(direction) or nvim_in_floating_win())
      and tmux_should_move(direction)
  end
end

---Map a key in normal and visual mode to a tmux command with fallback
---@param key string
---@param action string|function
---@param condition? fun(): boolean
---@param opts? vim.keymap.set.Opts
---@return nil
local function tmux_mapkey_fallback(key, action, condition, opts)
  condition = condition or tmux_mapkey_default_condition
  require('utils.key').amend({ 'n', 'x' }, key, function(fallback)
    if not condition() or vim.env.NVIM then
      fallback()
      return
    end
    if type(action) == 'string' then
      tmux_exec(action)
      return
    end
    action()
  end, opts)
end

---Setup keymaps and tmux variable `@is_vim`
---@return nil
local function setup()
  if vim.g.loaded_tmux or not vim.env.TMUX or not vim.g.has_ui then
    return
  end
  vim.g.loaded_tmux = true

  -- stylua: ignore start
  tmux_mapkey_fallback('<M-h>', navigate_wrap('h'), tmux_mapkey_navigate_condition('h'), { desc = 'Go to the left window or tmux pane' })
  tmux_mapkey_fallback('<M-j>', navigate_wrap('j'), tmux_mapkey_navigate_condition('j'), { desc = 'Go to the window below or tmux pane' })
  tmux_mapkey_fallback('<M-k>', navigate_wrap('k'), tmux_mapkey_navigate_condition('k'), { desc = 'Go to the window above or tmux pane' })
  tmux_mapkey_fallback('<M-l>', navigate_wrap('l'), tmux_mapkey_navigate_condition('l'), { desc = 'Go to the right window or tmux pane' })

  tmux_mapkey_fallback('<M-Left>',  navigate_wrap('h'), tmux_mapkey_navigate_condition('h'), { desc = 'Go to the left window or tmux pane' })
  tmux_mapkey_fallback('<M-Down>',  navigate_wrap('j'), tmux_mapkey_navigate_condition('j'), { desc = 'Go to the window below or tmux pane' })
  tmux_mapkey_fallback('<M-Up>',    navigate_wrap('k'), tmux_mapkey_navigate_condition('k'), { desc = 'Go to the window above or tmux pane' })
  tmux_mapkey_fallback('<M-Right>', navigate_wrap('l'), tmux_mapkey_navigate_condition('l'), { desc = 'Go to the right window or tmux pane' })

  tmux_mapkey_fallback('<M-p>', 'last-pane', nil, { desc = 'Go to the previous window or tmux pane' })
  tmux_mapkey_fallback('<M-R>', 'swap-pane -U', nil, { desc = 'Rorate windows or tmux panes upwards' })
  tmux_mapkey_fallback('<M-r>', 'swap-pane -D', nil, { desc = 'Rorate windows or tmux panes downwords' })
  tmux_mapkey_fallback('<M-o>', "confirm 'kill-pane -a'", nil, { desc = 'Make current window or tmux panes the only one' })
  tmux_mapkey_fallback('<M-=>', "confirm 'select-layout tiled'", nil, { desc = 'Make all windows or tmux panes equal size' })
  tmux_mapkey_fallback('<M-c>', 'confirm kill-pane', tmux_mapkey_close_win_condition, { desc = 'Close current window or tmux pane' })
  tmux_mapkey_fallback('<M-q>', 'confirm kill-pane', tmux_mapkey_close_win_condition, { desc = 'Close current window or tmux pane' })
  tmux_mapkey_fallback('<M-<>', [[run "tmux resize-pane -x $(($(tmux display -p '#{pane_width}') - 2))"]], tmux_mapkey_resize_pane_horiz_condition, { desc = 'Decrease window width' })
  tmux_mapkey_fallback('<M-,>', [[run "tmux resize-pane -x $(($(tmux display -p '#{pane_width}') - 2))"]], tmux_mapkey_resize_pane_horiz_condition, { desc = 'Decrease window width' })
  tmux_mapkey_fallback('<M-.>', [[run "tmux resize-pane -x $(($(tmux display -p '#{pane_width}') + 2))"]], tmux_mapkey_resize_pane_horiz_condition, { desc = 'Increase window width' })
  tmux_mapkey_fallback('<M->>', [[run "tmux resize-pane -x $(($(tmux display -p '#{pane_width}') + 2))"]], tmux_mapkey_resize_pane_horiz_condition, { desc = 'Increase window width' })
  tmux_mapkey_fallback('<M-->', [[run "tmux resize-pane -y $(($(tmux display -p '#{pane_height}') - 2))"]], tmux_mapkey_resize_pane_vert_condition, { desc = 'Decrease window height' })
  tmux_mapkey_fallback('<M-+>', [[run "tmux resize-pane -y $(($(tmux display -p '#{pane_height}') + 2))"]], tmux_mapkey_resize_pane_vert_condition, { desc = 'Increase window height' })
  -- stylua: ignore end

  -- Set @is_vim and register relevant autocmds callbacks if not already
  -- in a vim/nvim session
  if tmux_get_pane_opt('@is_vim') == '' then
    tmux_set_pane_opt('@is_vim', 'yes')
    local groupid = vim.api.nvim_create_augroup('my.tmux.set_isvim', {})
    vim.api.nvim_create_autocmd('VimResume', {
      desc = 'Set @is_vim in tmux pane options after vim resumes.',
      group = groupid,
      callback = function()
        tmux_set_pane_opt('@is_vim', 'yes')
      end,
    })
    vim.api.nvim_create_autocmd({ 'VimSuspend', 'VimLeave' }, {
      desc = 'Unset @is_vim in tmux pane options on vim leaving or suspending.',
      group = groupid,
      callback = function()
        tmux_unset_pane_opt('@is_vim')
      end,
    })
  end
end

return {
  setup = setup,
}
