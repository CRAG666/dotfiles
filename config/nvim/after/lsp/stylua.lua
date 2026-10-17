---@type lsp.config
return {
  filetypes = { 'lua' },
  cmd = { 'stylua', '--lsp' },
  root_markers = { 'stylua.toml', '.stylua.toml', '.editorconfig' },
}
