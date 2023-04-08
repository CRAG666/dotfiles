local utils = require "utils"

-- Lsp keymaps

local M = {}
function M.setup(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  local maps = {
    {
      prefix = "g",
      maps = {
        { "D", vim.lsp.buf.declaration, "Goto Declaration", opts },
        -- { "d", vim.lsp.buf.definition, "Goto Definition", opts },
        { "dt", "<cmd>tab split | lua vim.lsp.buf.definition()<C}>", "Goto Definition in new Tab", opts },
        -- { "h", vim.lsp.buf.hover, "LSP Hover", opts },
        { "i", vim.lsp.buf.implementation, "Goto Implementation", opts },
      },
    },
    {
      prefix = "<leader>",
      maps = {
        { "D", vim.lsp.buf.type_definition, "LSP Type Definition", opts },
        { "aw", vim.lsp.buf.add_workspace_folder, "LSP Add Folder", opts },
        -- { "dt", require("lsp_lines").toggle, "Toggle Diagnostic", opts },
      },
    },
  }
  utils.maps(maps)
end

return M
