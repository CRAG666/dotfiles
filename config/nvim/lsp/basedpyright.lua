local root_markers = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
}
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  root_markers = root_markers,
  filetypes = { 'python' },
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions = true,
        inlayHints = {
          variableTypes = true,
        }
      },
    },
  },
  single_file_support = true,
}
