return {
  {
    "AckslD/muren.nvim",
    keys = {
      {
        "[r",
        ":MurenToggle<CR>",
        desc = "[r]eplace pattern",
      },
    },
    config = function()
      require("muren").setup()
    end,
  },
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        mode = { "n", "x" },
        "]r",
        function()
          require("ssr").open()
        end,
        desc = "[r]eplace structure",
      },
    },
    name = "ssr",
    config = function()
      require("ssr").setup {
        border = "rounded",
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        adjust_window = true,
        keymaps = {
          close = "q",
          next_match = "n",
          prev_match = "N",
          replace_confirm = "<cr>",
          replace_all = "<leader><cr>",
        },
      }
    end,
  },
}
