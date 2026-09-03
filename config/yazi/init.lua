local searchjump_config
do
	local f = io.open((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/eyes/mode", "r")
	local mode = f and (f:read("*l") or "light") or "light"
	if f then
		f:close()
	end
	mode = mode:gsub("%s+", "")

	if mode == "dark" then
		searchjump_config = {
			unmatch_fg = "#8a9a88",
			match_str_fg = "#d0dcc8",
			match_str_bg = "#243224",
			first_match_str_fg = "#d0dcc8",
			first_match_str_bg = "#3a3420",
			label_fg = "#d0dcc8",
			label_bg = "#223040",
			only_current = false,
			show_search_in_statusbar = false,
			auto_exit_when_unmatch = false,
			enable_capital_label = true,
		}
	else
		searchjump_config = {
			unmatch_fg = "#486040",
			match_str_fg = "#1a1a1a",
			match_str_bg = "#94cc88",
			first_match_str_fg = "#1a1a1a",
			first_match_str_bg = "#d0c890",
			label_fg = "#1a1a1a",
			label_bg = "#90bcd0",
			only_current = false,
			show_search_in_statusbar = false,
			auto_exit_when_unmatch = false,
			enable_capital_label = true,
		}
	end
end

require("starship"):setup()
require("full-border"):setup()
require("searchjump"):setup(searchjump_config)
require("no-status"):setup()
