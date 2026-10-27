---@type lsp.config
return {
  filetypes = { 'tex' },
  cmd = { 'texlab' },
  root_markers = {
    '.git',
    '.latexmkrc',
    'latexmkrc',
    '.texlabroot',
    'texlabroot',
    'Tectonic.toml',
  },
  settings = {
    texlab = {
      build = {
        executable = 'tectonic',
        args = {
          '-X',
          'compile',
          '%f',
          '-Zsearch-path=/latex',
          '--synctex',
          '--keep-logs',
          '--keep-intermediates',
        },
        onSave = false,
        forwardSearchAfter = false,
      },
      auxDirectory = '.',
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
      diagnosticsDelay = 300,
      latexFormatter = 'texlab',
      latexindent = { modifyLineBreaks = false },
      bibtexFormatter = 'texlab',
    },
  },
}
