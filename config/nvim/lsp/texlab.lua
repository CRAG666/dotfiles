return {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'bib' },
  root_markers = { 'Tectonic.toml', '.git', '*.bib' },
  settings = {
    texlab = {
      rootDirectory = nil,
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
      diagnosticsDelay = 300,
      latexFormatter = 'latexindent',
      latexindent = {
        ['local'] = nil,
        modifyLineBreaks = false,
      },
      bibtexFormatter = 'texlab',
      formatterLineLength = 80,
    },
  },
  on_attach = function(client, bufnr)
    require('code_runner.hooks.tectonic').build(
      '/bin/zathura',
      { '--keep-intermediates', '--keep-logs' }
    )
  end,
}
