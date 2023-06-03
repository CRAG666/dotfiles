-- local diagnostics_active = true
--
-- local function toggle_diagnostics()
--   diagnostics_active = not diagnostics_active
--   if diagnostics_active then
--     vim.diagnostic.show()
--   else
--     vim.diagnostic.hide()
--   end
-- end

-- Use an on_attach function to only map the following keys
local on_attach = function(on_attach_client)
  return function(client, bufnr)
    on_attach_client = on_attach_client or function() end
    on_attach_client(client, bufnr)
    require("config.lsp.highlighter").setup(client, bufnr)
    require("config.lsp.null-ls.formatters").setup(client, bufnr)
  end
end

local M = {}

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

function M.setup(server, on_attach_client)
  require("config.lsp.handlers").setup()
  local opts = {
    flags = {
      debounce_text_changes = 150,
    },
  }
  opts.capabilities = M.capabilities()
  opts.on_attach = on_attach(on_attach_client)
  -- null-ls
  require("config.lsp.null-ls").setup(opts)
  local config = vim.tbl_deep_extend("force", opts, server or {})
  if server.name == "sumneko_lua" then
    config.before_init = require("neodev.lsp").before_init
  end
  vim.lsp.start(config)
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
