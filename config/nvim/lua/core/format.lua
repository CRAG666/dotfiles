local fmt_group =
  vim.api.nvim_create_augroup('autoformat_cmds', { clear = true })

local dedicated_formatters = {
  stylua = true,
  prettier = true,
  prettierd = true,
  prettier_d = true,
  shfmt = true,
  tex_fmt = true,
  bibtex_tidy = true,
}

local function setup(event)
  local id = vim.tbl_get(event, 'data', 'client_id')
  local client = id and vim.lsp.get_client_by_id(id)
  if client == nil then
    return
  end

  if #vim.api.nvim_get_autocmds({ group = fmt_group, buf = event.buf }) > 0 then
    return
  end

  local buf_format = function(e)
    local preferred
    for _, formatter in ipairs(vim.lsp.get_clients({
      bufnr = e.buf,
      method = 'textDocument/formatting',
    })) do
      if
        dedicated_formatters[formatter.name]
        and (not preferred or formatter.id < preferred.id)
      then
        preferred = formatter
      end
    end
    vim.lsp.buf.format({
      bufnr = e.buf,
      id = preferred and preferred.id,
      async = false,
      timeout_ms = 5000,
    })
  end

  vim.api.nvim_create_autocmd('BufWritePre', {
    buf = event.buf,
    group = fmt_group,
    desc = 'Formatear archivo',
    callback = buf_format,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Configurar formatear al guardar',
  callback = setup,
})
