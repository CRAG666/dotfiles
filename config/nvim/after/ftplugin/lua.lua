require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  textwidth = 0,
  expandtab = true,
  autoindent = true,
  wrap = false,
  spell = false,
})
vim.g.mason = {
  'stylua',
  'shfmt',
  'lua-language-server',
  'efm',
  'luacheck',
}
vim.g.ts = { 'lua', 'luadoc', 'luap' }
