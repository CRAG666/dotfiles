local args, state = ...
local scroll = require("scroll")

local arg1 = args and args[1]
local OFF = (arg1 == "off")
local MAX_PER_COL = tonumber(arg1) or 2

-- Tiled views from these apps must not trigger mode adjustments: they are
-- short-lived dialogs/pickers that distort the column count.
local IGNORE_APPS = {
  ["dialog"]                                = true,
  ["pwvucontrol"]                           = true,
  ["nm-connection-editor"]                  = true,
  ["xdg-desktop-portal-gtk"]                = true,
  ["imv"]                                   = true,
  ["org.kde.polkit-kde-authentication-agent-1"] = true,
  ["polkit-gnome-authentication-agent-1"]   = true,
}

local function on_view_map(view, _)
  if not scroll.view_mapped(view) then return end

  local app_id = scroll.view_get_app_id(view)
  if app_id and IGNORE_APPS[app_id] then return end

  local container = scroll.view_get_container(view)
  if not container then return end
  if scroll.container_get_floating(container) then return end

  local workspace = scroll.container_get_workspace(container)
  if not workspace then return end

  -- Walk up to the top-level container (the column). Scroll's tree is
  -- workspace -> column (top-level) -> view container (bottom-level) -> view,
  -- so this is O(1) hops instead of scanning every column in the workspace.
  local column = container
  while true do
    local parent = scroll.container_get_parent(column)
    if not parent then break end
    column = parent
  end

  local count = #scroll.container_get_views(column)
  local desired = (count >= MAX_PER_COL) and "horizontal" or "vertical"
  if scroll.workspace_get_mode(workspace).mode ~= desired then
    scroll.workspace_set_mode(workspace, { mode = desired })
  end
end

-- Remove any callback registered by a previous run of this script so hot
-- reloads don't stack duplicate callbacks.
local prev = scroll.state_get_value(state, "view_map_id")
if prev then
  scroll.remove_callback(prev)
  scroll.state_set_value(state, "view_map_id", nil)
end

if OFF then return end

scroll.state_set_value(state, "view_map_id",
  scroll.add_callback("view_map", on_view_map, nil))
