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
      rootDirectory = nil,
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
      forwardSearch = {
        executable = nil,
        args = {},
      },
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
      diagnosticsDelay = 300,
      latexFormatter = 'texlab',
      latexindent = {
        ['local'] = nil,
        modifyLineBreaks = false,
      },
      bibtexFormatter = 'texlab',
      formatterLineLength = 80,
    },
  },
}
