local utils = require('utils')

---@type table<string, table<string, term_t>>
local terms = vim.defaulttable(function()
  return {}
end)

---@class term_t
---@field buf integer
---@field dir string
---@field type string type of the terminal, useful to flag dedicated terminal running TUI apps, e.g. aider
---@field chan integer channel associate with terminal buffer `buf`
---@field cmd string[] command to launch terminal, default to `$SHELL`
---@field check_interval integer timeout waiting for aider to render
---@field win_configs vim.api.keyset.win_config
---@field entered? boolean whether we have ever entered this terminal buffer
local term_t = {}

---@class term_opts_t
---@field dir? string path to project root directory where a terminal will be created
---@field buf? integer existing terminal buffer
---@field type? string type of the terminal, useful to flag dedicated terminal running TUI apps, e.g. aider
---@field cmd? string[] command to launch terminal
---@field check_interval? integer timeout in ms waiting for aider to render
---@field win_configs? table window configs, see `vim.api.nvim_open_win`

---@type term_opts_t
local default_opts = {
  type = '',
  win_configs = {
    split = 'below',
    win = 0,
  },
  check_interval = 1000,
  cmd = (function()
    local shell = vim.env.SHELL
    return shell and vim.fn.executable(shell) == 1 and { shell }
      or { '/bin/sh' }
  end)(),
}

---Create a new terminal
---@param opts? term_opts_t
---@return term_t?
function term_t:new(opts)
  opts = vim.tbl_deep_extend('force', default_opts, self, opts)

  local chat = (function()
    if opts and opts.buf then
      return self:_new_from_buf(opts)
    end
    return self:_new_from_dir(opts)
  end)()

  if not chat then
    return
  end

  -- Record chat to chats indexed by cwd
  local old_chat = terms[chat.type][chat.dir]
  if old_chat and old_chat.buf ~= chat.buf then
    old_chat:del()
  end
  terms[chat.type][chat.dir] = chat

  if chat:validate() then
    return chat
  end
end

---Create from existing terminal buffer
---@private
---@param opts? term_opts_t
---@return term_t?
function term_t:_new_from_buf(opts)
  if
    not opts
    or not opts.buf
    or not vim.api.nvim_buf_is_valid(opts.buf)
    or vim.bo[opts.buf].bt ~= 'terminal'
  then
    return
  end

  -- Create terminal, no need to call `jobstart` as job is already
  -- running in `buf`
  local term = setmetatable(
    vim.tbl_deep_extend('force', opts, {
      dir = utils.term.parse_name(vim.api.nvim_buf_get_name(opts.buf)),
      chan = vim.b[opts.buf].terminal_job_id,
    }),
    { __index = self }
  )

  return term --[[@as term_t]]
end

---@private
---@param opts? term_opts_t
---@return term_t?
function term_t:_new_from_dir(opts)
  if not opts then
    opts = {}
  end

  if not opts.dir then
    opts.dir = vim.fn.getcwd(0)
  elseif vim.fn.isdirectory(opts.dir) == 0 then
    vim.notify(
      string.format("[term] '%s' is not a valid directory", opts.dir),
      vim.log.levels.WARN
    )
    return
  end

  -- Create a terminal instance
  local term = setmetatable(
    vim.tbl_deep_extend('force', opts, {
      buf = vim.api.nvim_create_buf(false, true),
    }),
    { __index = self }
  )

  -- Launch command
  term.chan = vim.api.nvim_buf_call(term.buf, function()
    local exe = term.cmd and term.cmd[1]
    if not exe or vim.fn.executable(exe) == 0 then
      vim.notify_once(
        string.format('[term] `%s` is not executable', tostring(exe)),
        vim.log.levels.WARN
      )
      return 0
    end
    return vim.fn.jobstart(term.cmd, {
      term = true,
      cwd = opts.dir,
    })
  end)
  if term.chan <= 0 then
    return -- failed to run command
  end

  return term --[[@as term_t]]
end

---Remove terminal from list
function term_t:del()
  if self.dir and (terms[self.type][self.dir] or {}).buf == self.buf then
    terms[self.type][self.dir] = nil
  end
end

---Check if a terminal is valid, delete it if not
---@return boolean
function term_t:validate()
  local valid = self.buf
    and self.chan
    and vim.api.nvim_buf_is_valid(self.buf)
    and not vim.tbl_isempty(vim.api.nvim_get_chan_info(self.chan))
  if not valid then
    self:del()
  end
  return valid
end

---Get a valid terminal in `path`
---If `path` is not given, prefer current visible terminal, if any
---@param path? string file or directory path, default to cwd
---@param tab? number default to current tabpage
---@return term_t? terminal object at `path`
---@return boolean? is_new whether the chat is newly created or reused
function term_t:get(path, tab)
  if not path then
    path = vim.fn.getcwd(0)
    -- Check if there is any terminal visible in given tabpage
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab or 0)) do
      local buf = vim.fn.winbufnr(win)
      if vim.bo[buf].bt == 'terminal' then
        path = utils.term.parse_name(vim.api.nvim_buf_get_name(buf))
        break
      end
    end
  else
    while vim.uv.fs_stat(path).type ~= 'directory' do
      path = vim.fs.dirname(path)
    end
  end
  -- Normalized `path`, always use absolute path and include trailing slash
  path = vim.fn.fnamemodify(path, ':p')

  local term = terms[self.type or default_opts.type or ''][path]
  if term and term:validate() then
    return term, false
  end

  -- Terminal recorded, add existing terminal buffer at `path` or create new
  -- terminal buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local new_term = self:new({ buf = buf })
    if new_term and new_term.dir == path then
      return new_term, true
    end
  end

  return self:new({ dir = path }), true
end

---Open terminal in current tabpage
---@param enter? boolean enter the terminal window, default `true`
---@return integer? win window id of the opened terminal, `nil` or <= 0 if invalid
function term_t:open(enter)
  if not self:validate() then
    return
  end

  enter = enter ~= false
  -- Terminal already visible in current tabpage, switch to it
  local win = self:wins():next()
  if win then
    if enter then
      vim.api.nvim_set_current_win(win)
    end
    return win
  end

  -- Open a new window for the terminal buffer in current tabpage
  local win_configs_normalized = {}
  for k, v in pairs(self.win_configs) do
    if vim.is_callable(v) then
      win_configs_normalized[k] = v()
    end
  end
  local new_win =
    vim.api.nvim_open_win(self.buf, enter, win_configs_normalized)

  -- Default terminal settings does not apply if terminal is launched using
  -- `jobstart()` and opened using `nvim_open_win()`, so manually trigger
  -- `TermOpen` event on the first time entering the aider chat terminal
  -- buffer to apply them
  -- See `:h default-autocmds` and `lua/plugin/term.lua`
  if new_win > 0 and not self.entered then
    vim.api.nvim_win_call(new_win, function()
      vim.api.nvim_exec_autocmds('TermOpen', { buffer = self.buf })
    end)
    self.entered = true
  end

  return win
end

---Close terminal window in current tabpage
function term_t:close()
  for win in self:wins() do
    -- Don't close the only window in current tabpage
    -- Try switching to alternative buffer to "close" the terminal
    if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
      local alt_buf = vim.fn.bufnr('#')
      if alt_buf > 0 and alt_buf ~= self.buf then
        vim.api.nvim_set_current_buf(alt_buf)
      end
      break
    end
    vim.api.nvim_win_close(win, true)
  end
end

---Toggle terminal
function term_t:toggle()
  if self:wins():peek() then
    self:close()
  else
    self:open()
  end
end

---Get windows containing terminal buffer in given `tabpage`
---@param tabpage? integer tabpage id, default to current tabpage
---@return Iter wins iterator of windows containing terminal if it is visible in given tabpage, else `nil`
function term_t:wins(tabpage)
  if not self:validate() then
    return vim.iter({})
  end

  if not tabpage then
    tabpage = vim.api.nvim_get_current_tabpage()
  elseif not vim.api.nvim_tabpage_is_valid(tabpage) then
    return vim.iter({})
  end

  return vim.iter(vim.api.nvim_tabpage_list_wins(tabpage)):filter(function(win)
    return vim.fn.winbufnr(win) == self.buf
  end)
end

---Send `lines` from `buf` to terminal
---@param msg string|string[]
function term_t:send(msg)
  if type(msg) ~= 'table' then
    msg = { msg }
  end

  utils.term.send(msg, self.buf)
end

---Call `cb` on terminal buffer update
---@param cb fun(chat: term_t): any
---@param tick? integer previous update's `b:changedtick`, should be `nil` on first call
function term_t:on_update(cb, tick)
  if not self:validate() then
    return
  end

  local cur_tick = vim.b[self.buf].changedtick

  -- Cancel following calls if callback returns a truethy value
  if cur_tick ~= tick and cb(self) then
    return
  end

  -- Schedule for next update
  vim.defer_fn(function()
    self:on_update(cb, cur_tick)
  end, self.check_interval)
end

return term_t
