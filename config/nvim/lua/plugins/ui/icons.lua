return {
  "nvim-tree/nvim-web-devicons",
  dependencies = { "DaikyXendo/nvim-material-icon", "jonathan-elize/nvim-icon-colorizer" },
  config = function()
    require("nvim-web-devicons").setup {
      override = require("nvim-material-icon").get_icons(),
    }
  end,
}

-- override = {
--     norg = {
--       icon = "",
--       color = "#428850",
--       cterm_color = "65",
--       name = "Norg"
--     }
-- };
