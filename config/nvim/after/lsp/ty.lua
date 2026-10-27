---@type lsp.config
return {
  filetypes = { 'python' },
  cmd = { 'ty', 'server' },
  root_markers = {
    { 'ty.toml' },
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
  -- The default info level writes every request to stderr, i.e. to the LSP log
  init_options = { logLevel = 'warn' },
  settings = {
    -- ruff reports syntax errors too
    ty = { showSyntaxErrors = false },
  },
}
