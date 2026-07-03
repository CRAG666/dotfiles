vim.bo.commentstring = '# %s'
vim.g.ts = { 'asm' }

-- Parse assembler diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l: %m]]
