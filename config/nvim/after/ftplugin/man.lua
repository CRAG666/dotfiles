if vim.bo.ma then
  return
end

require('utils.ftplugin')(
  {
    buflisted = false,
    list = false,
    number = false,
    relativenumber = false,
    scrolloff = 999,
    signcolumn = 'no',
    spell = false,
    statuscolumn = '',
  },
  'silent! nunmap <buffer> d | silent! xunmap <buffer> d | silent! nunmap <buffer> u | silent! xunmap <buffer> u'
)

vim.keymap.set({ 'n', 'x' }, 'd', '<C-d>', { buffer = true, nowait = true })
vim.keymap.set({ 'n', 'x' }, 'u', '<C-u>', { buffer = true, nowait = true })
