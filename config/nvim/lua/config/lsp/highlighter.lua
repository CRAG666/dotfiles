local M = {}

local notify = require "utils.notify"
local api = vim.api

M.highlight = true

function M.toggle()
  M.highlight = not M.highlight
  if M.highlight then
    notify.info("Enabled document highlight", "Document Highlight")
  else
    notify.warn("Disabled document highlight", "Document Highlight")
  end
end

function M.highlight(client, bufnr)
  if M.highlight then
    if client.server_capabilities.documentHighlightProvider then
      local lsp_highlight_grp = api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
      api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.schedule(vim.lsp.buf.document_highlight)
        end,
        group = lsp_highlight_grp,
        buffer = bufnr,
      })
      api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          vim.schedule(vim.lsp.buf.clear_references)
        end,
        group = lsp_highlight_grp,
        buffer = bufnr,
      })
    end
  end
end

function M.setup(client, bufnr)
  M.highlight(client, bufnr)
end

return M
