vim.bo.expandtab = false
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 0
vim.bo.tabstop = 4
vim.g.ts = { 'make' }

-- Parse gcc/clang diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l: %m]]
