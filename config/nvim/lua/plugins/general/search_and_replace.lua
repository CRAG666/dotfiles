return {
  {
    "AckslD/muren.nvim",
    keys = {
      {
        "<r",
        ":MurenToggle<CR>",
      },
    },
    config = function()
      require("muren").setup()
    end,
  },
  {
    "cshuaimin/ssr.nvim",
    name = "ssr",
    keys = {
      {
        mode = { "n", "x" },
        ",r",
        function()
          require("ssr").open()
        end,
      },
    },
    opts = {
      min_width = 50,
      min_height = 5,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_all = "<leader><cr>",
      },
    },
  },
}
