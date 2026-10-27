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
  -- ty hovers with types, ruff only with rule docs
  on_init = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
