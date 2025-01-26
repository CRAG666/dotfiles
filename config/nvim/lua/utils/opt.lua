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

---Get the location where the option is last set from
---@param opts vim.api.keyset.option?
---@return boolean
function opt_util_t:was_locally_set(opts)
  local info = vim.api.nvim_get_option_info2(self.name, opts or {})
  return info.last_set_chan ~= 0
    or info.last_set_linenr ~= 0
    or info.last_set_sid ~= 0
end

return setmetatable({}, {
  __index = function(self, name)
    self[name] = opt_util_t:new(name)
    return self[name]
  end,
})
