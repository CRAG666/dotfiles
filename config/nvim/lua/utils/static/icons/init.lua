local meta = {}

function meta:__index(key)
  for _, icons in pairs(self) do
    if icons[key] then
      return icons[key]
    end
  end
  return meta[key]
end

---Flatten the layered icons table into a single type-icon table.
---@return table<string, string>
function meta:flatten()
  local result = {}
  for _, icons in pairs(self) do
    for type, icon in pairs(icons) do
      result[type] = icon
    end
  end
  return result
end

return setmetatable(
  vim.g.modern_ui and require "utils.static.icons._icons" or require "utils.static.icons._icons_ascii",
  meta
)
