local utils = require "config.lsp.utils"
local icons = require "utils.static.icons"
local M = {}

local function lsp_init()
  -- Diagnostic configuration
  vim.diagnostic.config {
    underline = false,
    virtual_text = false,
    -- virtual_text = { spacing = 4, prefix = "●" },
    -- virtual_text = {
    --   severity = {
    --     min = vim.diagnostic.severity.ERROR,
    --   },
    -- },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.DiagnosticSignError,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.DiagnosticSignWarn,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.DiagnosticSignInfo,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.DiagnosticSignHint,
      },
      severity_sort = true,
      -- virtual_lines = true,
    },
  }

  -- Hover configuration
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  })
end

function M.setup(server, on_attach)
  utils.on_attach(function(client, bufnr)
    require("config.lsp.highlighter").on_attach(client, bufnr)
    require("config.lsp.format").on_attach(client, bufnr)
    require("config.lsp.keymaps").on_attach(client, bufnr)
    lsp_init()
    if on_attach ~= nil then
      on_attach(client, bufnr)
    end
  end)
  server.capabilities = utils.capabilities()
  local fs = require "utils.fs"
  server.root_dir =
    fs.proj_dir(vim.api.nvim_buf_get_name(0), vim.list_extend(server.root_patterns or {}, fs.root_patterns or {}))
  server.root_patterns = nil
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
