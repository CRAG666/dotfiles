local scroll = require("scroll")
local function candidate(view)
	local app_id = scroll.view_get_app_id(view)
	if app_id == "mpv" then
		local pview = scroll.view_get_parent_view(view)
		if pview ~= nil and pview ~= view then
			local papp_id = scroll.view_get_app_id(pview)
			if papp_id == "kitty" then
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
		scroll.command(nil, "scratchpad show; floating toggle")
	end
end

scroll.add_callback("view_map", on_create, nil)
scroll.add_callback("view_unmap", on_destroy, nil)
