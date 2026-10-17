require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
  commentstring = '" %s',
})

if vim.fn.win_gettype() == 'command' then
  require('utils.ftplugin')({
    buflisted = false,
    number = false,
    relativenumber = false,
    signcolumn = 'no',
    statuscolumn = '',
  })
end

vim.g.ts = { 'vim', 'vimdoc' }
