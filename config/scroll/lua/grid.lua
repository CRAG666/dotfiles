local args, state = ...
local scroll = require("scroll")
local config_path = "/tmp/grid_config.json"

local debug_notify = function(msg)
	scroll.command(nil, 'exec notify-send "' .. msg .. '"')
end

local function save_grid_config(data)
	local f = io.open(config_path, "w")
	if f then
		f:write("return {\n")
		f:write("  active_workspaces = {\n")
		for ws, cfg in pairs(data.active_workspaces) do
			f:write(string.format("    ['%s'] = {%s},\n", ws, table.concat(cfg, ",")))
		end
		f:write("  }\n")
		f:write("}\n")
		f:close()
	end
	scroll.ipc_send("grid", data)
end

local function load_grid_config()
	local f = io.open(config_path, "r")
	if not f then
		return nil
	end
	f:close()

	local ok, data = pcall(dofile, config_path)
	return ok and data or nil
end

local column_limit = tonumber(args[2]) or 3
local fit_size = tonumber(args[3]) or 0
local grid_rows = tonumber(args[4]) or column_limit
local grid_columns = tonumber(args[5]) or grid_rows

local grid = scroll.state_get_value(state, "grid_state")
if grid == nil then
	local saved_data = load_grid_config()
	if saved_data then
		grid = {
			map_id = nil,
			unmap_id = nil,
			last_view = nil,
			active_workspaces = saved_data.active_workspaces or {},
		}
	else
		grid = {
			map_id = nil,
			unmap_id = nil,
			last_view = nil,
			active_workspaces = {},
		}
	end
	scroll.state_set_value(state, "grid_state", grid)
end

local function on_destroy(view, _)
	local workspace = scroll.focused_workspace()
	if not workspace then
		return
	end

	local ws_name = scroll.workspace_get_name(workspace)
	local tiling = scroll.workspace_get_tiling(workspace)
	if not grid["active_workspaces"][ws_name] then
		return
	end
	local children = scroll.container_get_children(tiling[1])

	if #tiling == 1 and #children == 1 then
		grid["active_workspaces"][ws_name] = nil
		scroll.workspace_set_mode(workspace, { insert = "after", focus = true })
		save_grid_config(grid)
	end
end
local function on_create_view(view, _)
	local focused_view = scroll.focused_view()
	local workspace = scroll.focused_workspace()
	if not workspace then
		return
	end

	local tiling = scroll.workspace_get_tiling(workspace)
	local current_ws_name = scroll.workspace_get_name(workspace)
	grid["last_view"] = focused_view

	-- Check if Grid Mode is active for this workspace
	local ws_config = grid["active_workspaces"][current_ws_name]
	if not ws_config then
		return
	end
	scroll.workspace_set_mode(workspace, { insert = "end" })

	local container = scroll.view_get_container(view)
	if ws_config[4] == 1 then
		scroll.command(container, "set_size h " .. (1 / ws_config[3]))
		scroll.command(container, "set_size v " .. (1 / ws_config[2]))
	end

	if #tiling > 1 then
		local target_tiling = nil
		-- Iterate through existing columns to find a gap based on column_limit
		for i = 1, #tiling - 1 do
			local prev_container = tiling[i]
			local children = scroll.container_get_children(prev_container)
			if children and #children < ws_config[1] then
				target_tiling = i
				break
			end
		end

		if target_tiling then
			local steps = (#tiling - target_tiling - 1) * 2 + 1
			for i = 1, steps do
				scroll.command(container, "move left nomode")
			end
		end
	end
	if focused_view then
		local focused_con = scroll.view_get_container(focused_view)
		scroll.container_set_focus(focused_con)
	end
end

local workspace = scroll.focused_workspace()
if not workspace then
	return
end
local ws_name = scroll.workspace_get_name(workspace)

local function ensure_callback()
	if not grid["map_id"] then
		grid["map_id"] = scroll.add_callback("view_map", on_create_view, nil)
	end
	if not grid["unmap_id"] then
		grid["unmap_id"] = scroll.add_callback("view_unmap", on_destroy, nil)
	end
	save_grid_config(grid)
end

if args[1] == "toggle" then
	if grid["active_workspaces"][ws_name] then
		grid["active_workspaces"][ws_name] = nil
		scroll.workspace_set_mode(workspace, { insert = "after", focus = true })
		debug_notify("Grid Mode: DISABLED for [" .. ws_name .. "]")
	else
		grid["active_workspaces"][ws_name] = { column_limit, grid_rows, grid_columns, fit_size }
		scroll.workspace_set_mode(workspace, { insert = "end", focus = true })
		debug_notify(
			string.format("Grid Mode: ENABLED for %s (Lim:%d, H:%d, V:%d)", ws_name, column_limit, grid_rows, grid_columns)
		)
	end
elseif args[1] == "disable" then
	grid["active_workspaces"][ws_name] = nil
	scroll.workspace_set_mode(workspace, { insert = "after", focus = true })
	debug_notify("Grid Mode: DISABLED for [" .. ws_name .. "]")
elseif args[1] == "enable" then
	grid["active_workspaces"][ws_name] = { column_limit, grid_rows, grid_columns, fit_size }
	scroll.workspace_set_mode(workspace, { insert = "end", focus = true })
	debug_notify(
		string.format("Grid Mode: ENABLED for %s (Lim:%d, H:%d, V:%d)", ws_name, column_limit, grid_rows, grid_columns)
	)
end
ensure_callback()
