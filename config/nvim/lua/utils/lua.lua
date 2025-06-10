local M = {}

---Recursively build a nested table from a list of keys and a value e.g.
---{ a, b, c }, 'hello' -> { a = { b = { c = 'hello' } } }
---@param keys string[] list of keys
---@param val any
---@return table
function M.nest(keys, val)
  return keys[1] and { [keys[1]] = M.nest({ unpack(keys, 2) }, val) } or val
end

---Unnest table with given delimiter e.g.
---{ a = { b = 'hello', c = 'world' } } -> { 'a.b' = 'hello', 'a.c' = 'world' }
---@param input table
---@param delim string? default to dot '.'
---@return table
function M.unnest(input, delim)
  delim = delim or '.'
  local result = {}

  ---@param tbl table
  ---@param prefix? string `nil` in the initial call
  local function traverse(tbl, prefix)
    -- Don't recurse down if `tbl` is list, e.g.
    -- for { a = { b = { 'apple', 'orange' } } }
    -- want: { 'a.b' = { 'apple', 'orange' } }
    -- not:  { 'a.b.1' = 'apple', 'a.b.2' = 'orange' }
    if type(tbl) ~= 'table' or vim.islist(tbl) then -- base case
      assert(prefix)
      result[prefix] = tbl
      return
    end
    for key, subtbl in pairs(tbl) do
      traverse(subtbl, prefix == nil and key or prefix .. delim .. key)
    end
  end

  traverse(input)
  return result
end

return M
