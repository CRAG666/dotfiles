return {
  "jinzhongjia/LspUI.nvim",
  event = "LspAttach",
  keys = {
    { "gh", "<cmd>LspUI hover<CR>", desc = "Hover doc" },
    { "gr", "<cmd>LspUI rename<CR>", desc = "Rename" },
    { mode = { "n", "v" }, "<C-.>", "<cmd>LspUI code_action<CR>", desc = "Code actions" },
    { "gp", "<cmd>LspUI peek_definition<CR>", desc = "Edit the definition file in this flaotwindow" },
    { ";dj", "<cmd>LspUI diagnostic next", desc = "Next error" },
    { ";dk", "<cmd>LspUI diagnostic prev", desc = "Next error" },
  },
  config = function()
    require("LspUI").setup()
  end,
}
