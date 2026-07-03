vim.cmd.runtime({
  'ftplugin/cpp.vim',
  bang = true,
})
vim.g.ts = { 'cuda' }

-- Parse gcc/clang diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l: %m]]
