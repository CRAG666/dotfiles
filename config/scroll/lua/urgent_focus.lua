local _, state = ...
local scroll = require("scroll")

local function on_urgent(view, _)
	local container = scroll.view_get_container(view)
	local workspace = scroll.container_get_workspace(container)
	if workspace then
		scroll.command(nil, 'workspace --no-auto-back-and-forth "' .. scroll.workspace_get_name(workspace) .. '"')
	end
	scroll.command(container, "focus")
end

local previous = scroll.state_get_value(state, "urgent_id")
if previous then
	scroll.remove_callback(previous)
end
scroll.state_set_value(state, "urgent_id", scroll.add_callback("view_urgent", on_urgent, nil))
