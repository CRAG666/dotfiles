-- If is quickfix list, always open it at the bottom of screen
if vim.fn.win_gettype() == 'quickfix' then
  vim.cmd.wincmd('J')
end

vim.bo.textwidth = 0
vim.bo.buflisted = false
vim.opt_local.list = false
vim.opt_local.spell = false
vim.opt_local.nu = false
vim.opt_local.rnu = false
vim.opt_local.winfixbuf = true
vim.opt_local.signcolumn = 'no'
vim.opt_local.statuscolumn = ''

-- Provides `:Cfilter` and `:Lfilter` commands
vim.cmd.packadd({
  args = { 'cfilter' },
  mods = { emsg_silent = true },
})
