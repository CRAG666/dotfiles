require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat<')
vim.g.ts = { 'typescript', 'javascript', 'tsx' }

-- Parse tsc + node diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f(%l\,%c): %t%*[^:]: %m,%*[ ]at %.%#(%f:%l:%c),%f:%l]]
