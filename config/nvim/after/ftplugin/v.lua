require('utils.ftplugin')({
  shiftwidth = 4,
  tabstop = 4,
  softtabstop = 0,
  expandtab = false,
  textwidth = 0,
  wrap = false,
  spell = false,
  commentstring = '// %s',
}, 'setlocal errorformat<')

-- Parse v compiler diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m]]
