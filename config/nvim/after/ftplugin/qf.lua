-- If is quickfix list, always open it at the bottom of screen
if vim.fn.win_gettype() == 'quickfix' then
  vim.cmd.wincmd('J')
end

require('utils.ftplugin')({
  buflisted = false,
  list = false,
  spell = false,
  number = false,
  relativenumber = false,
  signcolumn = 'no',
  statuscolumn = '',
  wrap = false,
})

-- Provides `:Cfilter` and `:Lfilter` commands
vim.cmd.packadd({
  args = { 'cfilter' },
  mods = { emsg_silent = true },
})
