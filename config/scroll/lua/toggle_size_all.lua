-- `toggle_size all 1.0 1.0` that also reaches window heights. scroll 1.12.21
-- applies the mode to columns only (fixed upstream in b5113f36, unreleased); a
-- window takes it when it gains or loses focus, and nothing else in the Lua
-- API or the commands carries it there. Each focus change reaches one more
-- window, so the loops make W of them, the minimum; but scroll re-arranges the
-- whole workspace on each one, so the total is Θ(W²): measured 0.8 ms at
-- W = 32, 3.8 ms at 128, 58 ms at 512.

local scroll = require("scroll")

local focused = scroll.focused_container()
scroll.command(nil, "toggle_size all 1.0 1.0", { commit = false })
for _, column in ipairs(scroll.workspace_get_tiling(scroll.focused_workspace())) do
	for _, window in ipairs(scroll.container_get_children(column)) do
		if window ~= focused then
			scroll.container_set_focus(window)
		end
	end
end
scroll.container_set_focus(focused)
