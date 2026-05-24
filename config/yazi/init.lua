require("starship"):setup()

require("full-border"):setup()

require("searchjump"):setup({
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
})

require("no-status"):setup()
