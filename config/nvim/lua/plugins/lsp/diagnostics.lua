return {
  "folke/trouble.nvim",
  name = "trouble",
  keys = {
    { ";dw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { ";dd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Show Diagnostics" },
    { "gR", "<cmd>TroubleToggle lsp_references<cr>" },
  },
  opts = {
    auto_close = true,
    signs = {
      -- icons / text used for a diagnostic
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
  },
}
