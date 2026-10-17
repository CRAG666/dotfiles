require('utils.ftplugin')({
  wrap = false,
  spell = false,
  foldmethod = 'manual',
  textwidth = 0,
})
vim.g.ts =
  { 'git_config', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore' }
