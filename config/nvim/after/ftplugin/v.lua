vim.bo.commentstring = '// %s'

-- Parse v compiler diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m]]
