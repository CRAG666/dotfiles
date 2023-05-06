return {
  { "wellle/targets.vim", event = "CursorMoved" },
  { "chaoren/vim-wordmotion", event = "CursorMoved" },
  {
    "kylechui/nvim-surround",
    keys = { { "cs" }, { "ds" }, { "ys" } },
    config = true,
  },
  -- Tim Pope docet
  { "tpope/vim-repeat", event = "CursorMoved" },
  {
    "cshuaimin/ssr.nvim",
    name = "ssr",
    keys = { {
      mode = { "n", "x" },
      ",r",
      function()
        require("ssr").open()
      end,
    } },
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
  {
    "adalessa/markdown-preview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
    ft = "markdown",
  },
}
