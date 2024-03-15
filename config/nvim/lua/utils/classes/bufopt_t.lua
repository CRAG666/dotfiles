local utils = require('utils')

---Mimic vim buffer options using vim.b (b:) and vim.g (g:)
---@class bufopt_t
---@field name string name of the buffer option
---@field default any default value for the buffer option
---@field augroup string augroup id
---@field initialized table<number, true> list of initialized buffers
local bufopt_t = {}

---@type table<string, bufopt_t>
local bufopts = {}

---Create a new bufopt_t object
---@param name string name of the buffer option
---@param default any default value for the buffer option
function bufopt_t:new(name, default)
  if bufopts[name] then
    return bufopts[name]
  end
  vim.g[name] = default
  local bufs = vim.api.nvim_list_bufs()
  local initialized = {}
  for _, buf in ipairs(bufs) do
    vim.b[buf][name] = default
    initialized[buf] = true
  end
  local new_opt = setmetatable({
    name = name,
    default = default,
    augroup = vim.api.nvim_create_augroup(
      'BufOpt' .. utils.string.snake_to_camel(name),
      {}
    ),
    initialized = initialized,
  }, { __index = self })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    group = new_opt.augroup,
    callback = function(info)
      local buf = info.buf
      if vim.api.nvim_buf_is_valid(buf) and not new_opt.initialized[buf] then
        vim.b[buf][name] = vim.g[name]
        new_opt.initialized[buf] = true
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeOut', 'BufUnload' }, {
    group = new_opt.augroup,
    callback = function(info)
      new_opt.initialized[info.buf] = nil
    end,
  })
  bufopts[name] = new_opt
  return new_opt
end

---Delete the buffer option
function bufopt_t:del()
  vim.g[self.name] = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.b[buf][self.name] = nil
  end
  vim.api.nvim_clear_autocmds({ group = self.augroup })
  bufopts[self.name] = nil
end

---Get the buffer option, mimic vim :set <option>?
---@param buf number? buffer number
---@return any
function bufopt_t:get(buf)
  return vim.b[buf or 0][self.name]
end

---Get the buffer option, mimic vim :setlocal <option>?
---@param buf number? buffer number
---@return any
function bufopt_t:getlocal(buf)
  return vim.b[buf or 0][self.name]
end

---Get the buffer option global value, mimic vim :setglobal <option>?
---@return any
function bufopt_t:getglobal()
  return vim.g[self.name]
end

---Print the buffer option, mimic vim :set <option>?
---@param buf number? buffer number
function bufopt_t:print(buf)
  vim.notify(vim.inspect(self:get(buf)))
end

---Print the buffer option, mimic vim :setlocal <option>?
---@param buf number? buffer number
function bufopt_t:printlocal(buf)
  vim.notify(vim.inspect(self:getlocal(buf)))
end

---Print the buffer option global value, mimic vim :setglobal <option>?
---@return any
function bufopt_t:printglobal()
  vim.notify(vim.inspect(self:getglobal()))
end

---Set the buffer option, mimic vim :set
---@param value any value to set the buffer option to
---@param buf number? buffer number
function bufopt_t:set(value, buf)
  vim.b[buf or 0][self.name] = value
  vim.g[self.name] = value
end

---Set the buffer option in given buf only, mimic vim :setlocal
---@param value any value to set the buffer option to
---@param buf number? buffer number
function bufopt_t:setlocal(value, buf)
  vim.b[buf or 0][self.name] = value
end

---Set buffer option global value, mimic vim :setglobal
---@param value any value to set the buffer option to
function bufopt_t:setglobal(value)
  vim.g[self.name] = value
end

---Toggle buffer option, mimic vim :set <option>!
---@param buf number? buffer number
function bufopt_t:toggle(buf)
  self:set(not self:get(buf), buf)
end

---Toggle buffer option, mimic vim :setlocal <option>!
---@param buf number? buffer number
function bufopt_t:togglelocal(buf)
  self:setlocal(not self:getlocal(buf), buf)
end

---Toggle buffer option global value, mimic vim :setglobal <option>!
function bufopt_t:toggleglobal()
  self:setglobal(not self:getglobal())
end

---Reset buffer option to default value, mimic vim :set <option>&
---@param buf number? buffer number
function bufopt_t:reset(buf)
  self:set(self.default, buf)
end

---Reset buffer option local value to default value,
---mimic vim :setlocal <option>&
---@param buf number? buffer number
function bufopt_t:resetlocal(buf)
  self:setlocal(self.default, buf)
end

---Reset buffer option global value to default value,
---mimic vim :setglobal <option>&
function bufopt_t:resetglobal()
  self:setglobal(self.default)
end

---Call corresponding function based on the scope set in parsed_args
---@param opts table
---@param action string
---@vararg any
---@return any
function bufopt_t:scope_action(opts, action, ...)
  if opts['global'] then
    return self[action .. 'global'](self, ...)
  end
  if opts['local'] then
    return self[action .. 'local'](self, ...)
  end
  return self[action](self, ...)
end

return bufopt_t
