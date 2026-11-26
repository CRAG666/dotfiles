local _, state = ...
local scroll = require("scroll")
local TERMINAL = "com.mitchellh.ghostty"
local swallowed = {}

local function launcher(view)
	if scroll.view_get_app_id(view) ~= "mpv" then
		return nil
	end
	local parent = scroll.view_get_parent_view(view)
	if parent == nil or scroll.view_get_app_id(parent) ~= TERMINAL then
		return nil
	end
	-- single-instance ghostty: every window shares one pid, so the parent lookup returns an arbitrary one
	local focused = scroll.focused_view()
	if
		focused ~= nil
		and scroll.view_get_app_id(focused) == TERMINAL
		and scroll.view_get_pid(focused) == scroll.view_get_pid(parent)
	then
		return focused
	end
	return parent
end

local function on_create(view, _)
	local terminal = launcher(view)
	if terminal ~= nil then
		swallowed[view] = terminal
		scroll.command(scroll.view_get_container(terminal), "move scratchpad")
	end
end

local function hidden_launcher(view)
	local terminal = launcher(view)
	if terminal == nil then
		return nil
	end
	for _, container in ipairs(scroll.scratchpad_get_containers()) do
		for _, hidden in ipairs(scroll.container_get_views(container)) do
			if
				scroll.view_get_app_id(hidden) == TERMINAL
				and scroll.view_get_pid(hidden) == scroll.view_get_pid(terminal)
			then
				return hidden
			end
		end
	end
	return nil
end

local function on_destroy(view, _)
	-- a config reload discards the Lua state: fall back to a hidden terminal of the launching process
	local terminal = scroll.view_get_container(swallowed[view] or hidden_launcher(view))
	swallowed[view] = nil
	if not scroll.container_get_scratchpad(terminal) then
		return
	end
	local workspace = scroll.container_get_workspace(scroll.view_get_container(view)) or scroll.focused_workspace()
	local restore = "move --no-auto-back-and-forth container to workspace "
		.. scroll.workspace_get_name(workspace)
		.. ", floating disable"
	if scroll.focused_view() == view then
		restore = restore .. ", focus"
	end
	scroll.command(terminal, restore)
end

for _, key in ipairs({ "map_id", "unmap_id" }) do
	local id = scroll.state_get_value(state, key)
	if id then
		scroll.remove_callback(id)
	end
end

scroll.state_set_value(state, "map_id", scroll.add_callback("view_map", on_create, nil))
scroll.state_set_value(state, "unmap_id", scroll.add_callback("view_unmap", on_destroy, nil))
