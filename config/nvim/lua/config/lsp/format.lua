local M = {}

M.autoformat = true

function M.toggle()
  M.autoformat = not M.autoformat
  vim.notify(
    M.autoformat and 'Enabled format on save' or 'Disabled format on save'
  )
end

function M.on_attach(client, buf)
  vim.o.formatexpr = 'v:lua.require"conform".formatexpr()'
  if
      client.config
      and client.config.capabilities
      and client.config.capabilities.documentFormattingProvider == false
  then
    return
  end
  if client:supports_method('textDocument/formatting') then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('LspFormat.' .. buf, {}),
      buffer = buf,
      callback = function()
        if M.autoformat then
          require("conform").format({ bufnr = buf, lsp_format = "fallback" })
        end
      end,
    })
  end
end

return M
