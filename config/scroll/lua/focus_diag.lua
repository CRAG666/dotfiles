-- Usage: lua focus_diag.lua <ul|ur|dl|dr>
-- If the target column has fewer rows than the current position, the row
-- index is clamped to the closest valid one. Out-of-range columns are a no-op.
-- The view's column is its parent container, so locating it is O(1) API calls;
-- the Lua API has no sibling lookup, so the neighbour column costs one scan of
-- the workspace's column ids.

local args = ...
local scroll = require("scroll")

local DIRS = {
	ul = { x = -1, y = -1 },
	ur = { x = 1, y = -1 },
	dl = { x = -1, y = 1 },
	dr = { x = 1, y = 1 },
}

local delta = args and DIRS[args[1]]
if not delta then
	return
end

local view = scroll.focused_view()
local con = view and scroll.view_get_container(view)
if not con or scroll.container_get_floating(con) then
	return
end
local ws = scroll.container_get_workspace(con)
if not ws then
	return
end
local col = scroll.container_get_parent(con) or con

-- Top-level containers are columns in horizontal layouts and rows in vertical
-- ones, so the axes swap there.
local across, along = delta.x, delta.y
if scroll.workspace_get_layout_type(ws) == "vertical" then
	across, along = delta.y, delta.x
end

local row
for index, candidate in ipairs(scroll.container_get_views(col)) do
	if candidate == view then
		row = index
		break
	end
end

local cols = scroll.workspace_get_tiling(ws)
local target_col
for index, candidate in ipairs(cols) do
	if candidate == col then
		target_col = cols[index + across]
		break
	end
end
if not row or not target_col then
	return
end

local target_views = scroll.container_get_views(target_col)
if #target_views == 0 then
	return
end
local target = scroll.view_get_container(target_views[math.min(math.max(row + along, 1), #target_views)])
if target then
	scroll.container_set_focus(target)
end
