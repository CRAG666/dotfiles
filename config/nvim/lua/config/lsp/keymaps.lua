local utils = require "utils"

-- Lsp keymaps

local M = {}
function M.setup(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  local lsp = vim.lsp.buf

  local maps = {
    {
      prefix = "g",
      maps = {
        { "d", lsp.definition, "Goto Definition", opts },
        { "D", lsp.declaration, "Goto Declaration", opts },
        { "i", lsp.implementation, "Goto Implementation", opts },
        { "o", lsp.type_definition, "Type definition", opts },
        { "r", lsp.rename, "Rename", opts },
        { "s", lsp.signature_help, "Goto Implementation", opts },
        { "y", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "Goto Definition in new Tab", opts },
        { "h", lsp.hover, "LSP Hover", opts },
      },
    },
    {
      prefix = "<leader>",
      maps = {
        { "aw", vim.lsp.buf.add_workspace_folder, "LSP Add Folder", opts },
        -- { "dt", require("lsp_lines").toggle, "Toggle Diagnostic", opts },
      },
    },
  }
  utils.maps(maps)
  utils.map("n", "<C-.>", lsp.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
  utils.map("x", "<C-.>", lsp.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
end

return M
