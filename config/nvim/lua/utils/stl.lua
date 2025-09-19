local M = {}

---Get string representation of a string with highlight
---@param str? string sign symbol
---@param hl? string name of the highlight group
---@param restore? boolean restore highlight after the sign, default true
---@return string sign string representation of the sign with highlight
function M.hl(str, hl, restore)
  hl = hl or ''
  str = str or ''
  restore = restore == nil or restore
  return restore and table.concat({ '%#', hl, '#', str, '%*' })
    or table.concat({ '%#', hl, '#', str })
end

---Make a winbar string clickable
---@param str string
---@param callback string
---@return string
function M.make_clickable(str, callback)
  return string.format('%%@%s@%s%%X', callback, str)
end

---Escape '%' with '%' in a string to avoid it being treated as a statusline
---field, see `:h 'statusline'`
---@param str string
---@return string
function M.escape(str)
  return (str:gsub('%%', '%%%%'))
end

---@type stl_spinner_t[]
local spinners = {}

---@class stl_spinner_t
---@field opts stl_spinner_opts_t
---@field id integer
---@field timer uv.uv_timer_t
---@field icon string icon of the spinner
---@field changed_tick integer timestamp when the spinner icons is changed last time
---@field status 'spinning'|'finish'|'idle'
---@field attached_buf? integer buffer the spinner is attached to
---@field attached_autocmd? integer autocmd for the attach
M.spinner = {}

---@class stl_spinner_opts_t
---@field frame_interval? integer time interval between spinner frames (ms)
---@field finish_timeout? integer time to show finish icon before clearing (ms)
---@field icons? { progress: string[], finish: string }
---@field on_spin? fun(spinner: stl_spinner_t) function to execute on each update
---@field on_finish? fun(spinner: stl_spinner_t) function to execute on stop

---@type stl_spinner_opts_t
M.spinner.default_opts = {
  frame_interval = 80,
  finish_timeout = 1000,
  icons = vim.g.has_nf and {
    progress = { '⣷', '⣯', '⣟', '⡿', '⢿', '⣻', '⣽', '⣾' },
    finish = vim.trim(require('utils.static.icons').Ok),
  } or {
    progress = {
      '[    ]',
      '[=   ]',
      '[==  ]',
      '[=== ]',
      '[ ===]',
      '[  ==]',
      '[   =]',
    },
    finish = '[done]',
  },
}

local spinner_id = -1

---Create a new spinner instance
---@param opts stl_spinner_opts_t?
---@return stl_spinner_t
function M.spinner:new(opts)
  spinner_id = spinner_id + 1

  opts = not opts and M.spinner.default_opts
    or vim.tbl_deep_extend('keep', opts, M.spinner.default_opts)
  spinners[spinner_id] = setmetatable({
    opts = opts,
    id = spinner_id,
    icon = '',
    status = 'idle',
    timer = vim.uv.new_timer(),
    last_change = vim.uv.now(),
  }, { __index = self })

  return spinners[spinner_id]
end

---Delete the spinner instance and clean up resources
function M.spinner:del()
  spinners[self.id] = nil -- dereference self from the lookup table
  if self.status == 'spinning' then
    self:finish()
  end
  self.timer:close()
  for key, _ in pairs(self) do
    self[key] = nil
  end
end

---Start or continue spinning animation
---@param on_spin? fun(spinner: stl_spinner_t)
function M.spinner:spin(on_spin)
  on_spin = on_spin or self.opts.on_spin

  local now = vim.uv.now()

  -- Don't interrupt finish state if it hasn't displayed for
  -- `finish_timeout` ms
  if
    self.status == 'finish'
    and now - self.changed_tick < self.opts.finish_timeout
  then
    return
  end

  self.changed_tick = now
  self.icon = self.opts.icons.progress[math.ceil(
    now / self.opts.frame_interval
  ) % #self.opts.icons.progress + 1]

  -- Start timer if not already spinning
  if self.status ~= 'spinning' then
    self.status = 'spinning'
    self.timer:start(
      0,
      self.opts.frame_interval,
      vim.schedule_wrap(function()
        self:spin(on_spin)
      end)
    )
  end

  if on_spin then
    on_spin(self)
  end

  self:redraw()
end

---Show finish icon and stop spinning
---@param on_finish? fun(spinner: stl_spinner_t)
function M.spinner:finish(on_finish)
  on_finish = on_finish or self.opts.on_finish

  -- Can only enter `finish` state from `spinning` state
  if self.status ~= 'spinning' then
    return
  end
  self.status = 'finish'
  self.timer:stop()

  local now = vim.uv.now()
  self.changed_tick = now
  self.icon = self.opts.icons.finish

  if on_finish then
    on_finish(self)
  end

  self:redraw()

  -- Clear the icon after timeout
  vim.defer_fn(function()
    local n = vim.uv.now()
    -- Don't clear if not in `finish` state or icon changed after this
    -- `spinner:finish()` call
    if self.status ~= 'finish' or self.changed_tick ~= now then
      return
    end
    self.status = 'idle'
    self.changed_tick = n
    self.icon = ''
    self:redraw()
  end, self.opts.finish_timeout)
end

---Redraw so that the new icon can be shown in statusline
function M.spinner.redraw()
  -- Silent occasional treesitter error on text deletion
  pcall(vim.cmd.redrawstatus, {
    bang = true,
    mods = {
      emsg_silent = true,
    },
  })
end

---Attach spinner to buffer
---
---The spinner will be deleted when the buffer is wiped out or being detached
---from the buffer
---
---Spinners and buffers have one-to-one correspondence:
--- - A spinner can only be attached to at most one buffer
--- - A buffer can only have at most one spinner attached
---@param buf? integer
function M.spinner:attach(buf)
  buf = vim._resolve_bufnr(buf)

  local b = vim.b[buf]
  if b.spinner_id == self.id then
    return -- already attached
  end

  -- Self attached to another buffer, detach first
  if self.attached_buf and self.attached_buf ~= buf then
    self:detach()
  end

  -- Buffer have another spinner attached, detach it first
  if b.spinner_id then
    local spinner = M.spinner.get_by_id(b.spinner_id)
    if spinner then
      spinner:detach()
    end
  end

  b.spinner_id = self.id
  self.attached_buf = buf
  if not self.attached_autocmd then
    self.attached_autocmd = vim.api.nvim_create_autocmd('BufWipeout', {
      once = true,
      buffer = buf,
      callback = function(args)
        if vim.b[args.buf].spinner ~= self then
          return
        end
        self:detach()
      end,
    })
  end
end

---Detach spinner from buffer
---@param del? boolean whether to delete the spinner on detach, default true
function M.spinner:detach(del)
  del = del == nil or del

  local buf = self.attached_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local b = vim.b[buf]
  if b.spinner_id ~= self.id then
    return -- already detached
  end

  b.spinner_id = nil
  self.attached_buf = nil
  if self.attached_autocmd then
    pcall(vim.api.nvim_del_autocmd, self.attached_autocmd)
    self.attached_autocmd = nil
  end

  if del then
    self:del()
  end
end

---@param id? integer
---@return stl_spinner_t?
function M.spinner.get_by_id(id)
  if not id then
    return
  end
  return spinners[id]
end

---@param id? integer
---@return boolean
function M.spinner.id_is_valid(id)
  if not id then
    return false
  end
  return spinners[id] ~= nil
end

return M
