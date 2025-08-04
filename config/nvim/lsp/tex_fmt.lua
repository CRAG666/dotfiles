---@type lsp_config_t
return {
  filetypes = { 'tex' },
  cmd = { 'efm-langserver' },
  name = 'tex_fmt',
  requires = { 'tex-fmt' },
  root_markers = { 'Tectonic.toml' },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  settings = {
    languages = {
      tex = {
        {
          formatCommand = 'tex-fmt --wraplen 120 -s -p',
          formatStdin = true,
          formatCanRange = true,
        },
      },
    },
  },
}
