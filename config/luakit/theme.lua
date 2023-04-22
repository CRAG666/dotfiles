--------------------------
-- Default luakit theme --
--------------------------

local theme = {}

-- Default settings
theme .font = "12px monospace"

theme .fg   = "#FFF"
theme .bg   = "#000"


-- General colours
theme .success_fg = "#0F0"
theme .loaded_fg  = "#33AADD"

-- Error colours
theme .error_fg = "#FFF"
theme .error_bg = "#F00"

-- Warning colours
theme .warning_fg = "#F00"
theme .warning_bg = "#FFF"

-- Notification colours
theme .notif_fg = "#444"
theme .notif_bg = "#CFC"


-- Menu colours
theme .menu_fg                   = "#000"
theme .menu_bg                   = "#FFF"

theme .menu_selected_fg          = "#000"
theme .menu_selected_bg          = "#FF0"

theme .menu_title_bg             = "#FFF"
theme .menu_primary_title_fg     = "#F00"
theme .menu_secondary_title_fg   = "#666"

theme .menu_disabled_fg = "#999"
theme .menu_disabled_bg = theme .menu_bg

theme .menu_enabled_fg = theme .menu_fg
theme .menu_enabled_bg = theme .menu_bg

theme .menu_active_fg = "#060"
theme .menu_active_bg = theme .menu_bg


-- Proxy manager
theme .proxy_active_menu_fg      = '#000'
theme .proxy_active_menu_bg      = '#FFF'

theme .proxy_inactive_menu_fg    = '#888'
theme .proxy_inactive_menu_bg    = '#FFF'


-- Statusbar specific    https://this.that.the/other/
theme .sbar_fg         = "#FFF"
theme .sbar_bg         = "#000"


-- Downloadbar specific
theme .dbar_fg         = "#FFF"
theme .dbar_bg         = "#000"
theme .dbar_error_fg   = "#F00"


-- Input bar specific
theme .ibar_fg           = "#000"
theme .ibar_bg           = "#777"


-- Tab label
theme .tab_fg            = "#888"
theme .tab_bg            = "#222"

theme .tab_hover_bg      = "#292929"
theme .tab_ntheme        = "#DDD"

theme .selected_fg       = "#FFF"
theme .selected_bg       = "#000"

theme .selected_ntheme   = "#DDD"

theme .loading_fg        = "#33AADD"
theme .loading_bg        = "#000"

theme .selected_private_tab_bg = "#3D295B"
theme .private_tab_bg    = "#22254A"


-- Trusted / untrusted ssl colours
theme .trust_fg          = "#0F0"
theme .notrust_fg        = "#F00"


-- Follow mode hints
theme .hint_font = "10px monospace, courier, sans-serif"

theme .hint_fg = "#FFF"
theme .hint_bg = "#000088"

theme .hint_border = "1px dashed #000"
theme .hint_opacity = "0.3"

theme .hint_overlay_bg = "#FF7"
theme .hint_overlay_border = "1px dotted #000"

theme .hint_overlay_selected_bg = "#0C0"
theme .hint_overlay_selected_border = theme .hint_overlay_border


-- General colour pairings
theme .ok = { fg = "#040",  bg = "#DED" }  --  insert text into forms

theme .warn = { fg = "#F00",  bg = "#CCC" }
theme .error = { fg = "#FFF",  bg = "#F00" }

return theme

-- vim: et:sw=4:ts=8:sts=4:tw=80
