local _, state = ...
local scroll = require("scroll")
local function candidate(view)
	local app_id = scroll.view_get_app_id(view)
	if app_id == "mpv" then
		local pview = scroll.view_get_parent_view(view)
		if pview ~= nil and pview ~= view then
			local papp_id = scroll.view_get_app_id(pview)
			if papp_id == "com.mitchellh.ghostty" then
				return scroll.view_get_container(pview)
			end
		end
	end
	return nil
end

local function on_create(view, _)
	local parent = candidate(view)
	if parent ~= nil then
		scroll.command(parent, "move scratchpad")
	end
end

local function on_destroy(view, _)
	local parent = candidate(view)
	if parent ~= nil then
		scroll.command(parent, "scratchpad show, floating disable")
	end
end

for _, key in ipairs({ "map_id", "unmap_id" }) do
	local id = scroll.state_get_value(state, key)
	if id then
		scroll.remove_callback(id)
	end
end

scroll.state_set_value(state, "map_id", scroll.add_callback("view_map", on_create, nil))
scroll.state_set_value(state, "unmap_id", scroll.add_callback("view_unmap", on_destroy, nil))
