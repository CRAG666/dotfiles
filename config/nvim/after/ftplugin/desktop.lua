require('utils.ftplugin')({
  textwidth = 0,
  wrap = false,
  spell = false,
  formatoptions = vim.bo.formatoptions:gsub('t', ''),
})
vim.g.ts = { 'desktop' }
