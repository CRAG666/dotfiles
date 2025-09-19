vim.bo.commentstring = '" %s'

if vim.fn.win_gettype() == 'command' then
  vim.bo.textwidth = 0
  vim.bo.buflisted = false
  vim.opt_local.nu = false
  vim.opt_local.rnu = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.statuscolumn = ''
end
