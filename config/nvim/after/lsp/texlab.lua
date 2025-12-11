return {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'plaintex', 'bib' },
  root_markers = { 'main.tex', 'Tectonic.toml', '.git', '*.bib' },
  settings = {
    texlab = {
      rootDirectory = nil,
      auxDirectory = '.',
      forwardSearch = {
        executable = '/bin/zathura',
        args = { '--synctex-forward', '%l:1:%f', '%p' },
      },
      build = {
        executable = 'tectonic',
        args = {
          '-X',
          'compile',
          '%f',
          '--synctex',
          '--keep-logs',
          '--keep-intermediates',
          '-Zsearch-path=/latex',
        },
      },
      latexFormatter = 'texlab',
      bibtexFormatter = 'texlab',
    },
  },
}
