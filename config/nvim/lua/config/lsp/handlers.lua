local M = {}

function M.setup()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  -- LSP handlers configuration
  local config = {
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
    },

    diagnostic = {
      -- virtual_text = false,
      -- virtual_text = { spacing = 4, prefix = "●" },
      virtual_text = false,
      -- virtual_text = { severity = vim.diagnostic.severity.ERROR },
      virtual_lines = { prefix = "🔥" },
      signs = {
        active = signs,
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    },
  }

  -- Diagnostic configuration
  vim.diagnostic.config(config.diagnostic)

  -- Hover configuration
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)

  -- Signature help configuration
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
end

return M
