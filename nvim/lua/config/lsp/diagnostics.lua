local utils = require 'utils'

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      prefix = "",
      spacing = 4,
    },
    signs = true,
    virtual_text = true,
    update_in_insert = false,
  }
)

--[[ vim.fn.sign_define('LspDiagnosticsSignError', { text = "", texthl = "LspDiagnosticsDefaultError" })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = "", texthl = "LspDiagnosticsDefaultWarning" })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = "", texthl = "LspDiagnosticsDefaultInformation" })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = "", texthl = "LspDiagnosticsDefaultHint" }) ]]

require("trouble").setup {
    position = "right", -- position of the list can be: bottom, top, left, right
    signs = {
        -- icons / text used for a diagnostic
        error = " ",
        warning = " ",
        hint = "",
        information = " ",
        other = " "
    },
}


utils.map("n", "<leader>xx", "<cmd>Trouble<cr>",
  {silent = true, noremap = true}
)
utils.map("n", "<leader>xw", "<cmd>Trouble lsp_workspace_diagnostics<cr>",
  {silent = true, noremap = true}
)
utils.map("n", "<leader>xd", "<cmd>Trouble lsp_document_diagnostics<cr>",
  {silent = true, noremap = true}
)
utils.map("n", "<leader>xl", "<cmd>Trouble loclist<cr>",
  {silent = true, noremap = true}
)
utils.map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>",
  {silent = true, noremap = true}
)
utils.map("n", "gR", "<cmd>Trouble lsp_references<cr>",
  {silent = true, noremap = true}
)
