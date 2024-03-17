return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = { {
    "<leader>z",
    function()
      require("zen-mode").toggle()
    end,
    desc = "[z]en mode",
  } },
  opts = {
    window = {
      backdrop = 0.95,
      width = 90,
      height = 1,
    },
    on_open = function(win) end,
    -- callback where you can add custom code when the Zen window closes
    on_close = function() end,
  },
}
