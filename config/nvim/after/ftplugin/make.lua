require('utils.ftplugin')({
  expandtab = false,
  shiftwidth = 4,
  softtabstop = 0,
  tabstop = 4,
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat<')
vim.g.ts = { 'make' }

-- Parse gcc/clang diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l: %m]]
