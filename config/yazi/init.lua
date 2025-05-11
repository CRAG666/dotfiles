Header:children_add(function()
  if ya.target_family() ~= "unix" then
    return ""
  end
  return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("red")
end, 500, Header.LEFT)

require("full-border"):setup()

require("searchjump"):setup({
  unmatch_fg = "#A6ADC8",
  match_str_fg = "#1E1E2E",
  match_str_bg = "#A6E3A1",
  first_match_str_fg = "#1E1E2E",
  first_match_str_bg = "#A6E3A1",
  lable_fg = "#1E1E2E",
  lable_bg = "#89B4FA",
  only_current = false,
  show_search_in_statusbar = false,
  auto_exit_when_unmatch = false,
  enable_capital_lable = true,
})

require("no-status"):setup()
