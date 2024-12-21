return {
  "cbochs/grapple.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  keys = {
    { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "[m]ark file" },
    { "<leader>'", "<cmd>Grapple toggle_tags<cr>", desc = "Marked Files" },
    { "<leader>`", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple toggle scopes" },
    { "<leader>j", "<cmd>Grapple cycle forward<cr>", desc = "Grapple cycle forward" },
    { "<leader>k", "<cmd>Grapple cycle backward<cr>", desc = "Grapple cycle backward" },
  },
}
