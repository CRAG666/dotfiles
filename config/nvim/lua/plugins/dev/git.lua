return {
  "SuperBo/fugit2.nvim",
  opts = {
    width = 90,
    height = 55,
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    {
      "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
      dependencies = { "stevearc/dressing.nvim" },
    },
  },
  cmd = { "Fugit2", "Fugit2Diff", "Fugit2Graph" },
  keys = {
    { "<leader>gm", mode = "n", "<cmd>Fugit2<cr>" },
    { "<leader>gg", mode = "n", "<cmd>Fugit2Graph<cr>" },
  },
}
