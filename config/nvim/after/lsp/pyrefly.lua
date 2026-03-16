return {
  filetypes = { 'python' },
  cmd = { 'pyrefly', 'lsp' },
  root_markers = {
    { 'pyrefly.toml' },
    { 'pyproject.toml' },
    {
      'Pipfile',
      'requirements.txt',
      'setup.cfg',
      'setup.py',
      'tox.ini',
    },
    { 'venv', 'env', '.venv', '.env' },
    { '.python-version' },
  },
}
