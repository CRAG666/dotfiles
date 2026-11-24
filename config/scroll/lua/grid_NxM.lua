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
--
-- Complexity (C columns, W windows, cap constant so W = O(C)):
--   * Focus on a clean workspace: O(1). Workspaces are marked dirty by the
--     events that can unpack them (map, close, move, floating; scratchpad and
--     workspace moves arrive as move/floating) and on entering a workspace.
--     `selection move` emits no event: use `repack` after it.
--   * Repack: Θ(C). One tree read, then a linked list of view ids (stable
--     across moves) gives O(1) per move. Keeping window order forces one shift
--     per column right of a gap, so Θ(C) moves is the lower bound.
--   * Placement on map: O(1); the view's container sits inside its column.

local args, state = ...
local scroll = require("scroll")

local arg1 = args and args[1]
local OFF = (arg1 == "off")
local REPACK = (arg1 == "repack")
-- `repack` is a separate run, so it reads the cap the enabling run stored.
local MAX_PER_COL = tonumber(arg1) or (REPACK and scroll.state_get_value(state, "cap")) or 2

-- Flip to true and run scroll with `-d` to trace repack decisions.
local DEBUG = false
local function dbg(msg)
	scroll.log("[grid] " .. msg)
end

-- Short-lived dialogs/pickers must not drive grid placement.
local IGNORE_APPS = {
	["ghostty.dialog"] = true,
	["pwvucontrol"] = true,
	["nm-connection-editor"] = true,
	["xdg-desktop-portal-gtk"] = true,
	["imv"] = true,
	["org.kde.polkit-kde-authentication-agent-1"] = true,
	["polkit-gnome-authentication-agent-1"] = true,
}

-- IPC window changes that never alter column occupancy.
local LAYOUT_NEUTRAL = { focus = true, title = true, mark = true, urgent = true }

-- Workspace id -> true when it may be unpacked.
local dirty = {}
-- Closed view id -> its workspace id, until the view leaves the tree.
local closing = {}
local last_ws = nil

local function workspace_of(view)
	local con = scroll.view_get_container(view)
	return con and scroll.container_get_workspace(con)
end

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

-- New-window placement: keep filling the current column until the cap, then
-- switch the mode so the next window opens a fresh column. `view_map` runs
-- before the new window takes focus, so its workspace is dirty by then.
local function on_view_map(view, _)
	if not scroll.view_mapped(view) then
		return
	end
	local con = scroll.view_get_container(view)
	local ws = con and scroll.container_get_workspace(con)
	if ws then
		dirty[ws] = true
	end
	if not ws or is_ignored(view) or scroll.container_get_floating(con) then
		return
	end

	local col = scroll.container_get_parent(con) or con
	local count = #scroll.container_get_views(col)
	local new_col, same_col = modes_for(ws)
	scroll.workspace_set_mode(ws, { mode = (count >= MAX_PER_COL) and new_col or same_col })
end

-- A moved window may have left the focused workspace, so both get marked.
local function on_ipc_view(view, change, _)
	if LAYOUT_NEUTRAL[change] then
		return
	end
	local ws = workspace_of(view)
	if ws then
		dirty[ws] = true
		if change == "close" then
			closing[view] = ws
		end
	end
	local focused = scroll.focused_workspace()
	if focused then
		dirty[focused] = true
	end
end

-- Pull `source_view` (the first view of the column just right of the target)
-- into the target column with `move left nomode`. A lone window merges in one
-- move; a window with siblings is expelled into its own column first, then
-- merged -- exactly two. `source_col_count` tells us the move count up front.
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
-- column on the right, which a later iteration packs. Moves invalidate
-- container ids, so the tree is read once into a singly linked list of view-id
-- arrays and every move is mirrored in it in O(1). `busy` is raised right
-- before the first move, so the focus events the moves generate do not
-- re-enter. Returns whether anything moved.
local function repack(ws)
	local head, tail
	for _, col in ipairs(scroll.workspace_get_tiling(ws)) do
		local node = { views = scroll.container_get_views(col) }
		if tail then
			tail.next = node
		else
			head = node
		end
		tail = node
	end

	local moved = false
	local function begin_move()
		if not moved then
			moved = true
			scroll.state_set_value(state, "busy", true)
		end
	end

	local cur = head
	local guard = 0
	while cur do
		guard = guard + 1
		if guard > 1024 then
			break
		end
		local views = cur.views
		local n = #views
		if n == MAX_PER_COL then
			cur = cur.next
		elseif n > MAX_PER_COL then
			-- Over-full: expel the last view into its own column on the right;
			-- a later iteration packs it. Self-heals 3-stacks.
			local view = views[n]
			local con = scroll.view_get_container(view)
			if not con then
				break
			end
			begin_move()
			scroll.command(con, "move right nomode")
			views[n] = nil
			cur.next = { views = { view }, next = cur.next }
		else
			-- Under-full: pull the first view of the next column in.
			local nxt = cur.next
			if not nxt then
				break -- last column, below the cap: the grid is packed
			end
			local source = nxt.views
			local count = #source
			if count == 0 then
				break
			end
			local view = source[1]
			begin_move()
			if not pull_left(view, count) then
				break
			end
			if count == 1 then
				cur.next = nxt.next
			else
				table.remove(source, 1)
			end
			views[n + 1] = view
		end
	end
	if DEBUG then
		dbg("repack: moved=" .. tostring(moved))
	end
	return moved
end

-- Repack on focus changes, only when the workspace may be unpacked. A closed
-- window keeps its workspace dirty until it has left the tree.
local function on_view_focus(view, _)
	local ws = scroll.focused_workspace()
	if not ws or (ws == last_ws and not dirty[ws]) then
		return
	end
	if scroll.state_get_value(state, "busy") then
		return
	end
	last_ws = ws
	if repack(ws) then
		-- Moves may have shifted focus; put it back where the user left it.
		if view and scroll.view_mapped(view) then
			local c = scroll.view_get_container(view)
			if c then
				scroll.container_set_focus(c)
			end
		end
		scroll.state_set_value(state, "busy", nil)
	end
	local pending = nil
	for closed, closed_ws in pairs(closing) do
		if not scroll.view_get_container(closed) then
			closing[closed] = nil
		elseif closed_ws == ws then
			pending = true
		end
	end
	dirty[ws] = pending
end

-- One-shot manual repack (key binding). Guarded the same way.
local function manual_repack()
	local ws = scroll.focused_workspace()
	if ws and repack(ws) then
		scroll.state_set_value(state, "busy", nil)
	end
end

if REPACK then
	manual_repack()
	return
end

-- Drop callbacks/state from a previous run so reloads don't stack handlers.
for _, key in ipairs({ "map_id", "focus_id", "ipc_id" }) do
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

scroll.state_set_value(state, "cap", MAX_PER_COL)
scroll.state_set_value(state, "map_id", scroll.add_callback("view_map", on_view_map, nil))
scroll.state_set_value(state, "focus_id", scroll.add_callback("view_focus", on_view_focus, nil))
scroll.state_set_value(state, "ipc_id", scroll.add_callback("ipc_view", on_ipc_view, nil))
