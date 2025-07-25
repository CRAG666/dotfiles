require("starship"):setup()

require("full-border"):setup()

require("searchjump"):setup({
  unmatch_fg = "#7f849c",
  match_str_fg = "#1E1E2E",
  match_str_bg = "#b4befe",
  first_match_str_fg = "#1E1E2E",
  first_match_str_bg = "#cba6f7",
  label_fg = "#1E1E2E",
  label_bg = "#A6E3A1",
  only_current = false,
  show_search_in_statusbar = false,
  auto_exit_when_unmatch = false,
  enable_capital_label = true,
})

require("no-status"):setup()
