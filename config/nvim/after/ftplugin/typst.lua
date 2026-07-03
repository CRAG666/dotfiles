vim.g.ts = { 'typst' }
vim.g.mason = { 'tinymist' }

-- Parse typst diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%Eerror: %m,%Wwarning: %m,%Z%*[ ]┌─ %f:%l:%c,%Z%*[ ]--> %f:%l:%c]]
