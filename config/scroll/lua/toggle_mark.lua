-- toggle_mark.lua <spotlight.sh>: unmark the focused window's first mark, or
-- ask Spotlight for one when it has none. scroll keeps backslashes in quoted
-- arguments, so a stored mark quoted as is names itself.
local args = ...
local scroll = require("scroll")

local container = scroll.focused_container()
local mark = container and scroll.container_get_marks(container)[1]
if mark then
	scroll.command(container, 'unmark "' .. mark .. '"')
else
	scroll.command(nil, "exec " .. args[1] .. " mark-add")
end
