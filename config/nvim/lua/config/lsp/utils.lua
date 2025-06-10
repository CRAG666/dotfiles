local M = {}
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { 'markdown', 'plaintext' },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      },
    },
  }

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return require('blink.cmp').get_lsp_capabilities(capabilities)
end

function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd('LspAttach', {
    once = true,
    desc = 'Apply lsp',
    group = vim.api.nvim_create_augroup('LspSetup', {}),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, bufnr)
      return true
    end,
  })
end

return M
