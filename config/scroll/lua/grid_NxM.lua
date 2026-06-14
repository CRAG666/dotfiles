-- Auto NxM grid for scroll. Caps each column at MAX_PER_COL windows ("2 rows
-- tall, grow wide" by default). New windows fill the current column up to the
-- cap, then open a fresh column; when a window closes, the grid repacks so
-- columns stay full from left to right and never exceed the cap.
--
-- Invocation forms (see config keybindings):
--   lua grid_NxM.lua          enable with default cap (2)
--   lua grid_NxM.lua <N>      enable with cap N
--   lua grid_NxM.lua off      disable (remove callbacks)
--   lua grid_NxM.lua repack   one-shot manual repack of the focused workspace
--
-- Design notes (learned the hard way -- see git history / debug logs):
--   * Windows are relocated with `move ... nomode`, NOT `selection move`.
--     `selection move` crashes the compositor when a relocation empties a
--     column. `move nomode` is the documented, crash-safe way to insert a
--     window into a column.
--   * The repack runs on `view_focus`, never inside `view_unmap`. Mutating the
--     tree while a window is being destroyed crashes scroll, and scroll fires
--     no event once a window has actually left the tree. During a close the
--     dying window is still present, so the grid shows no gap and repack makes
--     no moves (safe no-op); the gap appears afterwards on a clean tree and is
--     filled on the next focus change. So every real move happens on a settled
--     tree. (Trade-off: a closed window's gap fills on the next focus action,
--     not the instant of the close -- the Lua API exposes no later hook.)

local args, state = ...
local scroll = require("scroll")

local arg1 = args and args[1]
local OFF = (arg1 == "off")
local REPACK = (arg1 == "repack")
local MAX_PER_COL = tonumber(arg1) or 2

-- Flip to true and run scroll with `-d` to trace repack decisions.
local DEBUG = false
local function dbg(msg)
	scroll.log("[grid] " .. msg)
end

-- Compact column-occupancy snapshot, e.g. "[2,2,1]". Debug only.
local function cols_str(ws)
	local parts = {}
	for ci, c in ipairs(scroll.workspace_get_tiling(ws)) do
		parts[ci] = tostring(#scroll.container_get_views(c))
	end
	return "[" .. table.concat(parts, ",") .. "]"
end

-- Short-lived dialogs/pickers must not drive grid placement.
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

-- In a horizontal-layout workspace, "horizontal" mode opens a new column and
-- "vertical" stacks inside it; mirrored for vertical layouts. Returns
-- (new_column_mode, same_column_mode).
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

-- New-window placement: keep filling the current column until the cap, then
-- switch the mode so the next window opens a fresh column.
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
	local new_col, same_col = modes_for(ws)
	scroll.workspace_set_mode(ws, { mode = (count >= MAX_PER_COL) and new_col or same_col })
end

-- Pull `source_view` (the first view of the column just right of the target)
-- into the target column with `move left nomode`. A lone window merges in one
-- move; a window with siblings is expelled into its own column first, then
-- merged -- exactly two. `source_col_count` (how many views shared source's
-- column) tells us the move count up front, so there's no need to rescan the
-- tree to detect when it landed -- O(1) instead of O(W). Window order within
-- the target column may change, but the grid shape is preserved.
local function pull_left(source_view, source_col_count)
	local moves = (source_col_count > 1) and 2 or 1
	for _ = 1, moves do
		local con = scroll.view_get_container(source_view)
		if not con then
			return false
		end
		scroll.command(con, "move left nomode")
	end
	return true
end

-- Normalise the workspace into left-packed columns of exactly MAX_PER_COL
-- (last column may hold fewer). Walks columns left-to-right: a column under the
-- cap pulls the first view of the next column in; a column over the cap (e.g. a
-- window opened into an already-full column) expels its last view into its own
-- column on the right, which a later iteration packs. The tree is re-read each
-- step because moves invalidate container pointers. On a packed grid it makes
-- no moves.
local function repack(ws)
	if DEBUG then
		dbg("repack: start cols=" .. cols_str(ws))
	end
	-- The column list is fetched once and reused while we only walk (idx++);
	-- it is re-fetched ONLY after a move, since moves invalidate container
	-- pointers. A packed grid is therefore a single O(C) walk with no re-fetch.
	local cols = scroll.workspace_get_tiling(ws)
	local idx = 1
	local guard = 0
	while idx <= #cols do
		guard = guard + 1
		if guard > 1024 then
			break
		end
		local cur_views = scroll.container_get_views(cols[idx])
		local n = #cur_views
		if n == MAX_PER_COL then
			idx = idx + 1
		elseif n > MAX_PER_COL then
			-- Over-full: expel the last view into its own column on the right;
			-- a later iteration packs it. Self-heals 3-stacks.
			local con = scroll.view_get_container(cur_views[n])
			if not con then
				break
			end
			scroll.command(con, "move right nomode")
			cols = scroll.workspace_get_tiling(ws)
		else
			-- Under-full: pull the first view of the next column in.
			local nxt = cols[idx + 1]
			if not nxt then
				break -- last column, below the cap: the grid is packed
			end
			local nxt_views = scroll.container_get_views(nxt)
			if #nxt_views == 0 then
				break
			end
			if not pull_left(nxt_views[1], #nxt_views) then
				break
			end
			cols = scroll.workspace_get_tiling(ws)
		end
	end
	if DEBUG then
		dbg("repack: done cols=" .. cols_str(ws))
	end
end

-- Repack on focus changes. `busy` guards against the focus events our own moves
-- (and the focus restore) generate, so we never re-enter.
local function on_view_focus(view, _)
	if scroll.state_get_value(state, "busy") then
		return
	end
	local ws = scroll.focused_workspace()
	if not ws then
		return
	end

	scroll.state_set_value(state, "busy", true)
	repack(ws)
	-- Moves may have shifted focus; put it back where the user left it.
	if view and scroll.view_mapped(view) then
		local c = scroll.view_get_container(view)
		if c then
			scroll.container_set_focus(c)
		end
	end
	scroll.state_set_value(state, "busy", nil)
end

-- One-shot manual repack (key binding). Guarded the same way.
local function manual_repack()
	local ws = scroll.focused_workspace()
	if not ws then
		return
	end
	scroll.state_set_value(state, "busy", true)
	repack(ws)
	scroll.state_set_value(state, "busy", nil)
end

if REPACK then
	manual_repack()
	return
end

-- Drop callbacks/state from a previous run so reloads don't stack handlers.
for _, key in ipairs({ "map_id", "focus_id" }) do
	local id = scroll.state_get_value(state, key)
	if id then
		scroll.remove_callback(id)
		scroll.state_set_value(state, key, nil)
	end
end
scroll.state_set_value(state, "busy", nil)

if OFF or MAX_PER_COL < 1 then
	return
end

scroll.state_set_value(state, "map_id", scroll.add_callback("view_map", on_view_map, nil))
scroll.state_set_value(state, "focus_id", scroll.add_callback("view_focus", on_view_focus, nil))
