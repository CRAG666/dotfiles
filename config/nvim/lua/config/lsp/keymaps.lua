local M = {}
function M.on_attach(_, buffer)
  local utils = require "utils"
  local lsp = vim.lsp.buf
  local bufopt = { buffer = buffer }

  vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"

  utils.map("n", ";dd", function()
    vim.diagnostic.setloclist { open = false } -- don't open and focus
    local window = vim.api.nvim_get_current_win()
    vim.cmd.lwindow() -- open+focus loclist if has entries, else close -- this is the magic toggle command
    vim.api.nvim_set_current_win(window)
  end, vim.tbl_extend("force", bufopt, { desc = "Open diagnostic loclist" }))

  -- vim.keymap.set("n", ";df", vim.diagnostic.open_float)

  local lsp_maps = {
    {
      prefix = "g",
      maps = {
        { "d", lsp.definition, "Goto Definition", bufopt },
        { "D", lsp.declaration, "Goto Declaration", bufopt },
        { "i", lsp.implementation, "Goto Implementation", bufopt },
        { "o", lsp.type_definition, "Type definition", bufopt },
        { "r", lsp.rename, "Rename", bufopt },
        { "s", lsp.signature_help, "Goto Implementation", bufopt },
        { "y", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "Goto Definition in new Tab", bufopt },
        { "h", lsp.hover, "LSP Hover", bufopt },
      },
    },
    {
      prefix = "<leader>",
      maps = {
        { "aw", vim.lsp.buf.add_workspace_folder, "LSP Add Folder", bufopt },
        -- { "dt", require("lsp_lines").toggle, "Toggle Diagnostic", bufopt },
      },
    },
  }
  utils.maps(lsp_maps)
  utils.map({ "n", "x" }, "<C-.>", lsp.code_action, vim.tbl_extend("force", bufopt, { desc = "Code actions" }))
end
return M
