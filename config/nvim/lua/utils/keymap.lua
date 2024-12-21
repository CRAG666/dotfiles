local M = {}

function M.has_width_gt(cols)
  -- Check if the windows width is greater than a given number of columns
  return vim.fn.winwidth(0) / 2 > cols
end

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.pmaps(mode, prefix, maps)
  mode = mode or "n"
  for _, map in pairs(maps) do
    local opts = { desc = map[3] }
    if map[4] then
      opts = vim.tbl_extend("force", opts, map[4])
    end
    M.map(mode, prefix .. map[1], map[2], opts)
  end
end

function M.maps(maps)
  for _, map in pairs(maps) do
    local mode = map.mode or "n"
    M.pmaps(mode, map.prefix, map.maps)
  end
end

---Set abbreviation that only expand when the trigger is at the position of
---a command
---@param trig string|{ [1]: string, [2]: string }
---@param command string
---@param opts table?
function M.command_abbrev(trig, command, opts)
  -- Map a range, first one if command short name,
  -- second one if command full name
  if type(trig) == "table" then
    local trig_short = trig[1]
    local trig_full = trig[2]
    for i = #trig_short, #trig_full do
      local cmd_part = trig_full:sub(1, i)
      M.command_abbrev(cmd_part, command)
    end
    return
  end
  vim.keymap.set("ca", trig, function()
    return vim.fn.getcmdcompltype() == "command" and command or trig
  end, vim.tbl_deep_extend("keep", { expr = true }, opts or {}))
end

---Set keymap that only expand when the trigger is at the position of
---a command
---@param trig string
---@param command string
---@param opts table?
function M.command_map(trig, command, opts)
  vim.keymap.set("c", trig, function()
    return vim.fn.getcmdcompltype() == "command" and command or trig
  end, vim.tbl_deep_extend("keep", { expr = true }, opts or {}))
end

return M
