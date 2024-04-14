return {
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    keys = {
      {
        "<leader><leader>r",
        function()
          require("rest-nvim").run()
        end,
        desc = "[r]un Endpoint",
      },
    },
    dependencies = { "luarocks.nvim" },
    config = function()
      require("rest-nvim").setup()
    end,
  },
}
