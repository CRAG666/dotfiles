---@class opt.indexer
---@field name string
local opt_indexer = {}
opt_indexer.__index = opt_indexer

---Create a new opt_util_t instance
---@param name string
---@return opt.indexer
function opt_indexer:new(name)
  return setmetatable({
    name = name,
  }, self)
end

---Get the location where the option is last set from
---@param opts vim.api.keyset.option?
---@return boolean
function opt_indexer:was_locally_set(opts)
  local info = vim.api.nvim_get_option_info2(self.name, opts or {})
  return info.last_set_chan ~= 0
    or info.last_set_linenr ~= 0
    or info.last_set_sid ~= 0
end

return setmetatable({}, {
  __index = function(self, name)
    self[name] = opt_indexer:new(name)
    return self[name]
  end,
})
