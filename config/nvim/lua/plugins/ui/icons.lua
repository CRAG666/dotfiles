return {
  "nvim-tree/nvim-web-devicons",
  dependencies = { "DaikyXendo/nvim-material-icon", "jonathan-elize/nvim-icon-colorizer" },
  config = function()
    require("nvim-web-devicons").setup {
      override = require("nvim-material-icon").get_icons(),
    }
  end,
}
