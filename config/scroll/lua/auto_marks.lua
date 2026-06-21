local _, state = ...
local scroll = require("scroll")

-- Patterns are matched against app_id with string.find (Lua patterns, not
-- exact match). First match wins.
local MARKS = {
	{ pattern = "firefox", mark = "b" },
	{ pattern = "zen", mark = "b" },
	{ pattern = "chromium", mark = "b" },
	{ pattern = "nvim", mark = "e" },
	{ pattern = "yazi", mark = "f" },
	{ pattern = "btop", mark = "s" },
}

local function on_view_map(view, _)
	if not scroll.view_mapped(view) then
		return
	end
	local app = scroll.view_get_app_id(view)
	if not app then
		return
	end

	for _, rule in ipairs(MARKS) do
		if app:find(rule.pattern) then
			local con = scroll.view_get_container(view)
			if con then
				scroll.command(con, "mark --add " .. rule.mark)
			end
			return
		end
	end
end

-- Drop any callback from a previous run so hot reloads don't stack duplicates.
local prev = scroll.state_get_value(state, "view_map_id")
if prev then
	scroll.remove_callback(prev)
	scroll.state_set_value(state, "view_map_id", nil)
end

scroll.state_set_value(state, "view_map_id", scroll.add_callback("view_map", on_view_map, nil))
