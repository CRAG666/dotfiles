vim.bo.sw = 4
vim.bo.cindent = false
vim.bo.smartindent = false
vim.bo.commentstring = '<!-- %s -->'
vim.opt_local.formatoptions:remove('t')
vim.g.mason = { 'marksman', 'remark-language-server' }
vim.g.ts = { 'markdown', 'markdown_inline' }
