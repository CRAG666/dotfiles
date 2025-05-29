local utils = require "utils.fn"
return {
  -- {
  --   "AckslD/muren.nvim",
  --   keys = {
  --     {
  --       "[r",
  --       ":MurenToggle<CR>",
  --       desc = "[r]eplace pattern",
  --     },
  --   },
  --   config = utils.setup "muren",
  -- },
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        mode = { "n", "x" },
        "<leader>sr",
        function()
          require("ssr").open()
        end,
        desc = "[S]earch [r]eplace structure",
      },
    },
    name = "ssr",
    config = utils.setup("ssr", {
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
    }),
  },
}
