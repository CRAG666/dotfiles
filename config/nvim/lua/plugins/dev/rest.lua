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
    dependencies = {
      "vhyrro/luarocks.nvim",
      config = function()
        require("luarocks").setup {}
      end,
    },
    config = function()
      require("rest-nvim").setup()
    end,
  },
}
