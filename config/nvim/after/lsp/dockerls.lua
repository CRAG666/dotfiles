return {
  cmd = { 'docker-langserver', '--stdio' },
  root_markers = {
    'Dockerfile',
  },
  filetypes = {
    'dockerfile',
  },
  single_file_support = true,
}
