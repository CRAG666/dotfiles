local root_markers = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
}
return {
  cmd = { 'ruff', 'server' },
  filetye = { 'python' },
  single_file_support = true,
  root_markers = root_markers,
  init_options = {
    settings = {
      args = { '--line-length=180' },
    },
  },
}
