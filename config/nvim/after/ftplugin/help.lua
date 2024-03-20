if vim.bo.ma then
  return
end

vim.bo.buflisted = false
vim.opt_local.conceallevel = 1
vim.opt_local.list = false
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = 'no'
vim.opt_local.spell = false
vim.opt_local.statuscolumn = ''
