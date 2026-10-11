local searchjump_config = {
	only_current = false,
	show_search_in_statusbar = false,
	auto_exit_when_unmatch = false,
	enable_capital_label = true,
}
for key, color in pairs(dofile((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/yazi/colors.lua")) do
	searchjump_config[key] = color
end

require("starship"):setup()
require("full-border"):setup()
require("searchjump"):setup(searchjump_config)
require("no-status"):setup()
