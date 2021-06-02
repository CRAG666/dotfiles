local lspc = require 'lspconfig'
require'lspkind'.init({})

local function make_base_config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {"documentation", "detail", "additionalTextEdits"}
    }
    return {capabilities = capabilities, on_attach = on_attach}
end

local flake8 = {
  lintCommand = "flake8 ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "black --line-length 79 ${INPUT}",
  formatStdin = true
}
-- capabilities = capabilities,
lspc.pyright.setup(make_base_config())
lspc.elixirls.setup(make_base_config())

lspc.efm.setup {
  init_options = {documentFormatting = true},
  --[[ root_dir = function()
    return vim.fn.getcwd()
  end, ]]
  settings = {
    rootMarkers = {".git/"},
    languages = {
      python = {flake8},
    }
  },
  filetypes = {
    "python",
  },
}
