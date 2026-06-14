require("starship"):setup()

require("full-border"):setup()

require("searchjump"):setup({
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
})

require("no-status"):setup()
