---@class fterm_t
---@field cmd string|string[]
---@field jobid integer
---@field buf integer
---@field win table<integer, integer>
---@field opts fterm_opts_t
local fterm_t = {}

local fterm_list_by_job = {} ---@type table<integer, fterm_t>
local fterm_list_by_buf = {} ---@type table<integer, fterm_t>

---@see termopen()
---@class fterm_jobopts_t
---@field clear_env boolean|nil `env` defines the job environment exactly, instead of merging current environment
---@field cwd string|nil default to current working directory
---@field detach boolean|nil detach the job process: it will not be killed when nvim exits
---@field env table<string, string>|nil map of environment variable name:value pairs
---@field on_exit function|nil
---@field on_stdout function|nil
---@field on_stderr function|nil
---@field overlapped boolean|nil
---@field rpc boolean|nil
---@field stderr_buffered boolean|nil
---@field stdout_buffered boolean|nil
---@field stdin string|nil

---@see nvim_open_win()
---@class fterm_winopts_t : vim.api.keyset.win_config
---@field col number?
---@field row number?
---@field width number?
---@field height number?
---...

---@class fterm_termopts_event_callback_t
---@field priority integer priority number larger than 0
---@field callback fun(term: fterm_t)

---@class fterm_termopts_event_callbacks_t
---@field on_new table<string, fterm_termopts_event_callback_t?>? callbacks to invoke when the terminal is first created, default callback has priority 100
---@field on_open table<string, fterm_termopts_event_callback_t?>? callbacks to invoke when the terminal window is opened, default callback has priority 100

---@class fterm_termopts_t
---@field toggle_keys string[]?
---@field event_callbacks fterm_termopts_event_callbacks_t?

---@class fterm_opts_t
---@field jobopts fterm_jobopts_t?
---@field winopts fterm_winopts_t?
---@field termopts fterm_termopts_t?

---@type fterm_opts_t
local fterm_opts_default = {
  termopts = {
    toggle_keys = {},
    event_callbacks = {
      on_new = {
        map_toggle_keys = {
          priority = 100,
          callback = function(term)
            local keys = term.opts.termopts.toggle_keys
            if keys then
              for _, key in ipairs(keys) do
                vim.keymap.set({ "n", "x", "t" }, key, function()
                  term:close()
                end, { buffer = term.buf })
              end
            end
          end,
        },
        auto_close = {
          priority = 100,
          callback = function(term)
            vim.api.nvim_create_autocmd("WinLeave", {
              buffer = term.buf,
              group = vim.api.nvim_create_augroup("FtermAutoClose" .. term.buf, {}),
              callback = function()
                term:close()
              end,
            })
          end,
        },
        auto_resize = {
          priority = 100,
          callback = function(term)
            vim.api.nvim_create_autocmd("VimResized", {
              buffer = term.buf,
              group = vim.api.nvim_create_augroup("FtermAutoResize" .. term.buf, {}),
              callback = function()
                term:update_win_size()
              end,
            })
          end,
        },
      },
      on_open = {
        auto_insert = {
          priority = 100,
          callback = function(_)
            vim.cmd.startinsert()
          end,
        },
        prevent_shifting = {
          priority = 100,
          callback = function(term)
            term:right_shift()
          end,
        },
      },
    },
  },
  jobopts = {
    on_exit = function(jobid, code, event)
      local term = fterm_t:get_by_job(jobid)
      if term and code == 0 and event == "exit" then
        term:del()
      end
    end,
  },
  winopts = {
    relative = "editor",
    border = vim.g.mordern_ui and "none" or "single",
    style = "minimal",
    width = 0.75,
    height = 0.75,
    row = 0.12,
    col = 0.125,
  },
}

---Normalize width/height/col/row relative to editor size or other base numbers
---@param number number
---@param base number
---@param rounding 'floor'|'ceil'|nil default to 'floor'
---@return integer
local function normalize_relative_geometry(number, base, rounding)
  rounding = rounding or "floor"
  if 0 < number and 1 > number then
    return math[rounding](number * base)
  end
  return math[rounding](number)
end

---Nomralize fterm window options
---@param winopts fterm_winopts_t?
---@return fterm_winopts_t
local function normalize_fterm_winopts(winopts)
  local columns = vim.o.columns
  local lines = math.max(1, vim.o.lines - vim.go.cmdheight - 1)
  local normalized_winopts = vim.deepcopy(winopts or {})
  -- stylua: ignore start
  normalized_winopts = vim.tbl_deep_extend('force', fterm_opts_default.winopts, normalized_winopts) --[[@as table]]
  normalized_winopts.width = normalize_relative_geometry(normalized_winopts.width, columns)
  normalized_winopts.height = normalize_relative_geometry(normalized_winopts.height, lines)
  normalized_winopts.row = normalize_relative_geometry(normalized_winopts.row, lines)
  normalized_winopts.col = normalize_relative_geometry(normalized_winopts.col, columns)
  -- stylua: ignore end
  if normalized_winopts.relative ~= "win" then
    normalized_winopts.win = nil
  end
  if vim.tbl_isempty(normalized_winopts) then
    normalized_winopts = vim.empty_dict() --[[@as table]]
  end
  return normalized_winopts
end

---Nomralize fterm job options
---@param jobopts fterm_jobopts_t?
---@return fterm_jobopts_t
local function normalize_fterm_jobopts(jobopts)
  local normalized_jobopts = vim.deepcopy(jobopts or {})
  normalized_jobopts = vim.tbl_deep_extend("force", fterm_opts_default.jobopts, normalized_jobopts) --[[@as table]]
  if vim.tbl_isempty(normalized_jobopts) then
    normalized_jobopts = vim.empty_dict() --[[@as table]]
  end
  return normalized_jobopts
end

---Nomralize fterm terminal options
---@param termopts fterm_termopts_t?
---@return fterm_termopts_t
local function normalize_fterm_termopts(termopts)
  local normalized_termopts = vim.deepcopy(termopts or {})
  normalized_termopts = vim.tbl_deep_extend("force", fterm_opts_default.termopts, normalized_termopts) --[[@as table]]
  return normalized_termopts
end

---Nomralize fterm options
---@param opts fterm_opts_t?
---@return fterm_opts_t
local function normalize_fterm_opts(opts)
  return {
    jobopts = normalize_fterm_jobopts(opts and opts.jobopts),
    winopts = normalize_fterm_winopts(opts and opts.winopts),
    termopts = normalize_fterm_termopts(opts and opts.termopts),
  }
end

---@param cmd string|string[]
---@param opts fterm_opts_t?
---@return fterm_t?
function fterm_t:new(cmd, opts)
  cmd = cmd or ""
  local normalized_opts = normalize_fterm_opts(opts)
  local buf = vim.api.nvim_create_buf(false, false)
  local win = vim.api.nvim_open_win(buf, true, normalized_opts.winopts)
  local jobid = vim.fn.termopen(cmd, normalized_opts.jobopts)
  if jobid <= 0 then -- Failed to start
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local term = setmetatable({
    buf = buf,
    win = { [tab] = win },
    cmd = cmd,
    opts = opts,
    jobid = jobid,
  }, { __index = self })

  fterm_list_by_job[jobid] = term
  fterm_list_by_buf[buf] = term

  term:exec_event_callbacks "on_new"
  term:exec_event_callbacks "on_open"

  return term
end

---Delete the terminal instance
---@return nil
function fterm_t:del()
  for tab, _ in pairs(self.win) do
    self:close(tab)
  end
  if self.jobid then
    vim.fn.jobstop(self.jobid)
  end
  if self:buf_is_valid() then
    vim.api.nvim_buf_delete(self.buf, { force = true })
  end
  fterm_list_by_job[self.jobid] = nil
  fterm_list_by_buf[self.buf] = nil
end

---@param event 'on_new'|'on_open'
function fterm_t:exec_event_callbacks(event)
  local normalized_opts = normalize_fterm_opts(self.opts)
  local event_callbacks = normalized_opts.termopts.event_callbacks[event]
  if event_callbacks then
    local sorted_callbacks = {}
    for _, callback in pairs(event_callbacks) do
      sorted_callbacks[callback.priority] = sorted_callbacks[callback.priority] or {}
      table.insert(sorted_callbacks[callback.priority], callback.callback)
    end
    for _, callbacks in pairs(sorted_callbacks) do
      for _, callback in pairs(callbacks) do
        if vim.is_callable(callback) then
          callback(self)
        end
      end
    end
  end
end

---Get the terminal instance by jobid
---@param jobid integer
---@return fterm_t?
function fterm_t:get_by_job(jobid)
  return fterm_list_by_job[jobid]
end

---Get the terminal instance by bufnr
---@param buf integer
---@return fterm_t?
function fterm_t:get_by_buf(buf)
  return fterm_list_by_buf[buf]
end

---Check if the terminal is visible in current tabpage
---@param tab integer? default to current tabpage
---@return boolean
function fterm_t:win_is_visible(tab)
  tab = tab or vim.api.nvim_get_current_tabpage()
  if not self.win or not self.win[tab] then
    return false
  end
  local win = self.win[tab]
  return vim.api.nvim_win_is_valid(win)
end

---Check if the terminal has a valid buffer
---@return boolean
function fterm_t:buf_is_valid()
  return self.buf and vim.api.nvim_buf_is_valid(self.buf) or false
end

---@return nil
function fterm_t:open()
  if self:win_is_visible() then
    return
  end

  -- Create a new terminal with the same config if the old buffer is not valid
  -- then replace the attributes of the old terminal with the new one
  if not self:buf_is_valid() then
    local new_term = self:new(self.cmd, self.opts)
    if new_term then
      for k, v in pairs(new_term) do
        self[k] = v
      end
    end
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  self.win[tab] = vim.api.nvim_open_win(self.buf, true, normalize_fterm_winopts(self.opts.winopts))
  self:exec_event_callbacks "on_open"
end

---Close the terminal windows in current tabpage
---@param tab integer? default to current tabpage
---@return nil
function fterm_t:close(tab)
  tab = tab or vim.api.nvim_get_current_tabpage()
  if not self:win_is_visible(tab) then
    return
  end
  vim.api.nvim_win_close(self.win[tab], true)
  self.win[tab] = nil
end

---@return nil
function fterm_t:toggle()
  if self:win_is_visible() then
    self:close()
  else
    self:open()
  end
end

---Update window size based on `opts.winopts`
---@return nil
function fterm_t:update_win_size()
  if not self:win_is_visible() then
    return
  end

  vim.api.nvim_win_set_config(self.win[vim.api.nvim_get_current_tabpage()], normalize_fterm_winopts(self.opts.winopts))

  self:right_shift()
end

---Shift the contents of the terminal to the right, prevent terminal contents
---from shifting left when the terminal window width is reduced
---@return nil
function fterm_t:right_shift()
  if
    vim.api.nvim_get_mode().mode:find "^t"
    and self:win_is_visible()
    and vim.api.nvim_get_current_win() == self.win[vim.api.nvim_get_current_tabpage()]
  then
    local eventignore = vim.o.eventignore
    vim.opt.eventignore:append "CursorMoved"
    vim.opt.eventignore:append "InsertEnter"
    vim.opt.eventignore:append "InsertLeave"
    vim.opt.eventignore:append "ModeChanged"
    vim.cmd.stopinsert()
    vim.api.nvim_feedkeys("0i", "n", false)
    vim.o.eventignore = eventignore
  end
end

return fterm_t
