return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.zsh|.command)',
    },
  },
  single_file_support = true,
}
