local utils = require "config.lsp.utils"
local M = {}

local function lsp_init()
  local signs = {
    { name = "DiagnosticSignError", text = Icons.diagnostics.bold_error },
    { name = "DiagnosticSignWarn", text = Icons.diagnostics.bold_warning },
    { name = "DiagnosticSignHint", text = Icons.diagnostics.bold_hint },
    { name = "DiagnosticSignInfo", text = Icons.diagnostics.bold_information },
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
      -- virtual_text = {
      --   severity = {
      --     min = vim.diagnostic.severity.ERROR,
      --   },
      -- },
      signs = {
        active = signs,
      },
      underline = false,
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
      -- virtual_lines = true,
    },
  }

  -- Diagnostic configuration
  vim.diagnostic.config(config.diagnostic)

  -- Hover configuration
  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)

  -- Signature help configuration
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
end

function M.setup(server)
  utils.on_attach(function(client, bufnr)
    require("config.lsp.highlighter").setup(client, bufnr)
    require("config.lsp.format").on_attach(client, bufnr)
    require("config.lsp.keymaps").on_attach(client, bufnr)
  end)

  lsp_init() -- diagnostics, handlers

  server.capabilities = utils.capabilities()
  -- null-ls
  if server.name == "sumneko_lua" then
    server.before_init = require("neodev.lsp").before_init
  end
  vim.lsp.start(server)
end

function M.remove_unused_imports()
  vim.diagnostic.setqflist { severity = vim.diagnostic.severity.WARN }
  vim.cmd "packadd cfilter"
  vim.cmd "Cfilter /main/"
  vim.cmd "Cfilter /The import/"
  vim.cmd "cdo normal dd"
  vim.cmd "cclose"
  vim.cmd "wa"
end

return M
