-- Auto NxM grid for scroll. Caps each column at MAX_PER_COL views and
-- repacks the grid when a window closes so columns stay full from left
-- to right. Re-run with a new arg to change cap or `off` to disable.
--
-- Invocation forms (see config keybindings):
--   lua grid_NxM.lua          enable with default cap (2)
--   lua grid_NxM.lua <N>      enable with cap N
--   lua grid_NxM.lua off      remove callbacks

local args, state = ...
local scroll = require("scroll")

local arg1 = args and args[1]
local OFF = (arg1 == "off")
local MAX_PER_COL = tonumber(arg1) or 2

-- Tiled views from these apps must not trigger mode adjustments: they are
-- short-lived dialogs/pickers that distort the column count.
local IGNORE_APPS = {
	["dialog"] = true,
	["pwvucontrol"] = true,
	["nm-connection-editor"] = true,
	["xdg-desktop-portal-gtk"] = true,
	["imv"] = true,
	["org.kde.polkit-kde-authentication-agent-1"] = true,
	["polkit-gnome-authentication-agent-1"] = true,
}

local function is_ignored(view)
	local app = scroll.view_get_app_id(view)
	return app ~= nil and IGNORE_APPS[app] == true
end

-- In a horizontal-layout workspace, "horizontal" mode opens a new column
-- and "vertical" mode stacks inside it. In vertical-layout workspaces
-- it's mirrored. Return both as (new_top_container_mode, same_top_mode).
local function modes_for(ws)
	local layout = scroll.workspace_get_layout_type(ws) or "horizontal"
	if layout == "vertical" then
		return "vertical", "horizontal"
	end
	return "horizontal", "vertical"
end

local function locate_view(view, ws)
	local cols = scroll.workspace_get_tiling(ws)
	for ci, col in ipairs(cols) do
		for _, v in ipairs(scroll.container_get_views(col)) do
			if v == view then
				return ci, col, cols
			end
		end
	end
end

-- After a window is mapped, point the workspace mode at the next slot:
-- keep filling the current column if it's below the cap, otherwise
-- switch so the next window opens a fresh column.
local function on_view_map(view, _)
	if not scroll.view_mapped(view) then
		return
	end
	if is_ignored(view) then
		return
	end

	local con = scroll.view_get_container(view)
	if not con or scroll.container_get_floating(con) then
		return
	end

	local ws = scroll.container_get_workspace(con)
	if not ws then
		return
	end

	local _, col = locate_view(view, ws)
	if not col then
		return
	end

	local count = #scroll.container_get_views(col)
	local new_top, same_top = modes_for(ws)
	if count >= MAX_PER_COL then
		scroll.workspace_set_mode(ws, { mode = new_top })
	else
		scroll.workspace_set_mode(ws, { mode = same_top })
	end
end

-- Move `source` so it lands at the end of `target_col`, after the last
-- view in it that isn't `exclude_view` (the about-to-die one) or `source`
-- itself. Uses selection because `selection move` is the only move that
-- documents honouring the workspace's insert-mode modifier.
local function move_to_end_of(source, target_col, exclude_view)
	local target_views = scroll.container_get_views(target_col)
	local anchor
	for i = #target_views, 1, -1 do
		local v = target_views[i]
		if v ~= exclude_view and v ~= source then
			anchor = v
			break
		end
	end
	if not anchor then
		return
	end

	local source_con = scroll.view_get_container(source)
	local anchor_con = scroll.view_get_container(anchor)
	if not source_con or not anchor_con or source_con == anchor_con then
		return
	end

	local ws = scroll.container_get_workspace(source_con)
	if not ws then
		return
	end

	local saved = scroll.workspace_get_mode(ws)
	local _, same_top = modes_for(ws)
	scroll.workspace_set_mode(ws, { mode = same_top, insert = "after" })

	scroll.command(nil, "selection reset")
	scroll.container_set_focus(source_con)
	scroll.command(nil, "selection toggle")
	scroll.container_set_focus(anchor_con)
	scroll.command(nil, "selection move")
	scroll.command(nil, "selection reset")

	if saved then
		local restore = {}
		if saved.mode == "horizontal" or saved.mode == "vertical" then
			restore.mode = saved.mode
		end
		if saved.insert then
			restore.insert = saved.insert
		end
		if next(restore) then
			scroll.workspace_set_mode(ws, restore)
		end
	end
end

-- After dying_view's column shrinks below the cap, cascade-pull the
-- first view of each subsequent column onto the end of the previous one.
-- The cascade stops once a column reaches the cap or there's nothing
-- left to pull.
local function repack(ws, dying_view)
	local cols = scroll.workspace_get_tiling(ws)

	local dying_col_idx
	for ci, col in ipairs(cols) do
		for _, v in ipairs(scroll.container_get_views(col)) do
			if v == dying_view then
				dying_col_idx = ci
				break
			end
		end
		if dying_col_idx then
			break
		end
	end
	if not dying_col_idx then
		return
	end

	-- If dying_view was alone in its column, scroll removes the empty
	-- column and shifts the rest left on its own; no manual work needed.
	local dying_col_remaining = 0
	for _, v in ipairs(scroll.container_get_views(cols[dying_col_idx])) do
		if v ~= dying_view then
			dying_col_remaining = dying_col_remaining + 1
		end
	end
	if dying_col_remaining == 0 then
		return
	end

	for ci = dying_col_idx, #cols - 1 do
		local cur_count = 0
		for _, v in ipairs(scroll.container_get_views(cols[ci])) do
			if v ~= dying_view then
				cur_count = cur_count + 1
			end
		end
		if cur_count >= MAX_PER_COL then
			break
		end

		local next_views = scroll.container_get_views(cols[ci + 1])
		if #next_views == 0 then
			break
		end

		move_to_end_of(next_views[1], cols[ci], dying_view)
	end
end

local function on_view_unmap(view, _)
	if is_ignored(view) then
		return
	end

	local con = scroll.view_get_container(view)
	if not con or scroll.container_get_floating(con) then
		return
	end

	local ws = scroll.container_get_workspace(con)
	if not ws then
		return
	end

	repack(ws, view)
end

-- Drop any callbacks from a previous run so hot-reloads don't stack
-- duplicate handlers and so `off` actually disables the grid.
for _, key in ipairs({ "map_id", "unmap_id" }) do
	local id = scroll.state_get_value(state, key)
	if id then
		scroll.remove_callback(id)
		scroll.state_set_value(state, key, nil)
	end
end

if OFF or MAX_PER_COL < 1 then
	return
end

scroll.state_set_value(state, "map_id", scroll.add_callback("view_map", on_view_map, nil))
scroll.state_set_value(state, "unmap_id", scroll.add_callback("view_unmap", on_view_unmap, nil))
