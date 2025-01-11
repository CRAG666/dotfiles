---@class opt_util_t
---@field name string
local opt_util_t = {}
opt_util_t.__index = opt_util_t

---Create a new opt_util_t instance
---@param name string
---@return opt_util_t
function opt_util_t:new(name)
  return setmetatable({
    name = name,
  }, self)
end

---Check whether the option is set from a modeline
---@param where string
---@return boolean
function opt_util_t:last_set_from(where)
  return vim.fn
    .execute(string.format('silent! verbose setlocal %s?', self.name))
    :match('Last set from ' .. where) ~= nil
end

---Get the location where the option is last set from
---@return string?
function opt_util_t:last_set_loc()
  return vim.fn
    .execute(string.format('silent! verbose setlocal %s?', self.name))
    :match('Last set from (%S*)')
end


return setmetatable({}, {
  __index = function(self, name)
    self[name] = opt_util_t:new(name)
    return self[name]
  end,
})
