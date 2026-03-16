---@type lsp.config
return {
  filetypes = { 'python' },
  cmd = { 'ruff', 'server' },
  buf_support = false,
  root_markers = {
    { 'ruff.toml', '.ruff.toml' },
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
