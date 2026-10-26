require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = true,
  linebreak = true,
  breakindent = true,
  spell = true,
}, 'setlocal errorformat<')

vim.g.ts = { 'typst' }

-- Parse typst diagnostics (code_runner quickfix mode)
vim.bo.errorformat =
  [[%Eerror: %m,%Wwarning: %m,%Z%*[ ]┌─ %f:%l:%c,%Z%*[ ]--> %f:%l:%c]]
