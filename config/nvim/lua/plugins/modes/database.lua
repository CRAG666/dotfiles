return {
  "kndndrj/nvim-dbee",
  key = {
    "<leader>dd",
    function()
      require("dbee").toggle()
    end,
    desc = "Databse mode",
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    require("dbee").install()
  end,
  config = function()
    require("dbee").setup()
  end,
}
