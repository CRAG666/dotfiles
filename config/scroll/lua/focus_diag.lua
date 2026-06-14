-- Usage: lua focus_diag.lua <ul|ur|dl|dr>
-- If the target column has fewer rows than the current position, the row
-- index is clamped to the closest valid one. Out-of-range columns are a no-op.

local args, state = ...
local scroll = require("scroll")

local DIRS = {
  ul = { dcol = -1, drow = -1 },
  ur = { dcol =  1, drow = -1 },
  dl = { dcol = -1, drow =  1 },
  dr = { dcol =  1, drow =  1 },
}

local dir = args and args[1]
local delta = dir and DIRS[dir]
if not delta then return end

local focused = scroll.focused_view()
if not focused then return end

local container = scroll.view_get_container(focused)
if not container then return end
if scroll.container_get_floating(container) then return end

local ws = scroll.container_get_workspace(container)
if not ws then return end

local cols = scroll.workspace_get_tiling(ws)

local cur_col, cur_row
for ci, col in ipairs(cols) do
  local views = scroll.container_get_views(col)
  for vi, v in ipairs(views) do
    if v == focused then
      cur_col, cur_row = ci, vi
      break
    end
  end
  if cur_col then break end
end

if not cur_col then return end

local target_col = cols[cur_col + delta.dcol]
if not target_col then return end

local target_views = scroll.container_get_views(target_col)
if #target_views == 0 then return end

local target_row = cur_row + delta.drow
if target_row < 1 then target_row = 1 end
if target_row > #target_views then target_row = #target_views end

local target_container = scroll.view_get_container(target_views[target_row])
if target_container then
  scroll.container_set_focus(target_container)
end
