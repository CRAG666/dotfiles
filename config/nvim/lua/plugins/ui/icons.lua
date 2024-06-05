return {
  -- {
  --   "nvim-tree/nvim-web-devicons",
  --   lazy = true,
  --   dependencies = { "DaikyXendo/nvim-material-icon", "jonathan-elize/nvim-icon-colorizer" },
  --   config = function()
  --     require("nvim-web-devicons").setup {
  --       -- override = require("nvim-material-icon").get_icons(),
  --     }
  --   end,
  -- },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      local theme_colors = require("catppuccin.palettes").get_palette "mocha"

      require("tiny-devicons-auto-colors").setup {
        colors = theme_colors,
      }
    end,
  },
}

-- override = {
--     norg = {
--       icon = "",
--       color = "#428850",
--       cterm_color = "65",
--       name = "Norg"
--     }
-- };
