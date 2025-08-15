vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'noselect' }
vim.opt.shortmess:append('c')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(
        true,
        client.id,
        ev.buf,
        { autotrigger = true }
      )
    end
  end,
})
