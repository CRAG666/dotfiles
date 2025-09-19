---@type lsp_config_t
return {
  filetypes = { 'bib' },
  cmd = { 'efm-langserver' },
  name = 'bibtex_tidy',
  requires = { 'bibtex-tidy' },
  root_markers = { 'Tectonic.toml' },
  init_options = {
    documentFormatting = true,
  },
  settings = {
    languages = {
      bib = {
        {
          formatCommand = 'bibtex-tidy --v2 --curly --numeric --align=13 --blank-lines --duplicates=key,doi,citation,abstract --merge --sort-fields --remove-empty-fields --wrap=106',
          formatStdin = true,
        },
      },
    },
  },
}
