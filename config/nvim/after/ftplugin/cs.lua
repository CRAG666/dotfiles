require('utils.ftplugin')({
  shiftwidth = 4,
  tabstop = 4,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat< | silent! nunmap <buffer> <leader>;')
vim.g.mason = { 'roslyn' }
vim.g.ts = { 'c_sharp', 'jsonnet' }

-- Set ; to end line
vim.keymap.set(
  'n',
  '<leader>;',
  '<esc>mzA;<esc>`z',
  { buffer = true, silent = true }
)

-- Parse dotnet/msbuild diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f(%l\,%c): %t%*[^:]: %m,%f(%l\,%c): %m]]
