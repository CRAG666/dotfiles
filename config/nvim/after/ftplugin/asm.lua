require('utils.ftplugin')({
  shiftwidth = 4,
  tabstop = 4,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
  commentstring = '# %s',
}, 'setlocal errorformat<')
vim.g.ts = { 'asm' }

-- Parse assembler diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f:%l: %m]]
