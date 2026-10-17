require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  cinoptions = ':0g0(0s',
  commentstring = '// %s',
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat<')
vim.g.ts = { 'cuda' }

-- Parse gcc/clang diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l: %m]]
