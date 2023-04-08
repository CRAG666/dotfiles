--------------------------
-- Default luakit theme --
--------------------------

local theme = {}

-- Default settings
theme.font = "12px monospace"
theme.fg   = "#fff"
theme.bg   = "#000"

-- Genaral colours
theme.success_fg = "#7ad88e"
theme.loaded_fg  = "#8accfe"
theme.error_fg = "#FFF"
theme.error_bg = "#e68183"

-- Warning colours
theme.warning_fg = "#e68183"
theme.warning_bg = "#FFF"

-- Notification colours
theme.notif_fg = "#FFF"
theme.notif_bg = "#111416"

-- Menu colours
theme.menu_fg                   = "#fff"
theme.menu_bg                   = "#111416"
theme.menu_selected_fg          = "#c8cccc"
theme.menu_selected_bg          = "#111416"
theme.menu_title_bg             = "#111416"
theme.menu_primary_title_fg     = "#f00"
theme.menu_secondary_title_fg   = "#666"

theme.menu_disabled_fg = "#999"
theme.menu_disabled_bg = theme.menu_bg
theme.menu_enabled_fg = theme.menu_fg
theme.menu_enabled_bg = theme.menu_bg
theme.menu_active_fg = "#060"
theme.menu_active_bg = theme.menu_bg

-- Proxy manager
theme.proxy_active_menu_fg      = '#000'
theme.proxy_active_menu_bg      = '#FFF'
theme.proxy_inactive_menu_fg    = '#888'
theme.proxy_inactive_menu_bg    = '#FFF'

-- Statusbar specific
theme.sbar_fg         = "#bf616a"
theme.sbar_bg         = "#111416"

-- Downloadbar specific
theme.dbar_fg         = "#fff"
theme.dbar_bg         = "#111416"
theme.dbar_error_fg   = "#e68183"

-- Input bar specific
theme.ibar_fg           = "#fff"
theme.ibar_bg           = "#111416"

-- Tab label
theme.tab_fg            = "#fff"
theme.tab_bg            = "#292a2b"
theme.tab_hover_bg      = "#444"
theme.tab_ntheme        = "#ddd"
theme.selected_fg       = "#fff"
theme.selected_bg       = "#111416"
theme.selected_ntheme   = "#ddd"
theme.loading_fg        = "#8accfe"
theme.loading_bg        = "#111416"

theme.selected_private_tab_bg = "#bb98eb"
theme.private_tab_bg    = "#d3a0ce"

-- Trusted/untrusted ssl colours
theme.trust_fg          = "#87af87"
theme.notrust_fg        = "#e68183"

-- Follow mode hints
theme.hint_font = "10px monospace, courier, sans-serif"
theme.hint_fg = "#fff"
theme.hint_bg = "#e39b7b"
theme.hint_border = "1px dashed #000"
theme.hint_opacity = "0.3"
theme.hint_overlay_bg = "#fee074"
theme.hint_overlay_border = "1px dotted #000"
theme.hint_overlay_selected_bg = "#87af87"
theme.hint_overlay_selected_border = theme.hint_overlay_border

-- General colour pairings
theme.ok = { fg = "#fff", bg = "#111416" }
theme.warn = { fg = "#e68183", bg = "#FFF" }
theme.error = { fg = "#FFF", bg = "#e68183" }

-- Gopher page style (override defaults)
theme.gopher_light = { bg = "#111416", fg = "#f2f2f2", link = "#89bfbc" }
theme.gopher_dark  = { bg = "#111416", fg = "#E8E8E8", link = "#ffd866" }

return theme

-- vim: et:sw=4:ts=8:sts=4:tw=80
