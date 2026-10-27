---@type lsp.config
return {
  filetypes = {
    'c',
    'cpp',
    'objc',
    'objcpp',
    'cuda',
  },
  -- `--log=error`: the default info level writes every request to stderr,
  -- i.e. to the LSP log
  cmd = { 'clangd', '--pch-storage=memory', '--log=error' },
  root_markers = {
    {
      '.clangd',
      '.clang-tidy',
      '.clang-format',
    },
    {
      'compile_commands.json',
      'compile_flags.txt',
      'configure.ac',
    },
  },
  -- clangd extensions, see https://clangd.llvm.org/extensions
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspClangdSwitchSourceHeader',
      function()
        client:request(
          'textDocument/switchSourceHeader',
          vim.lsp.util.make_text_document_params(bufnr),
          function(err, uri)
            if err or not uri then
              return vim.notify('[clangd] no corresponding source/header')
            end
            vim.cmd.edit(vim.uri_to_fname(uri))
          end,
          bufnr
        )
      end,
      { desc = 'Switch between source and header' }
    )
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspClangdShowSymbolInfo',
      function()
        client:request(
          'textDocument/symbolInfo',
          vim.lsp.util.make_position_params(0, client.offset_encoding),
          function(err, symbols)
            if err or not symbols or #symbols == 0 then
              return
            end
            vim.lsp.util.open_floating_preview({
              'name: ' .. symbols[1].name,
              'container: ' .. symbols[1].containerName,
            }, '', { focusable = false, title = 'Symbol Info' })
          end,
          bufnr
        )
      end,
      { desc = 'Show symbol info' }
    )
  end,
}
