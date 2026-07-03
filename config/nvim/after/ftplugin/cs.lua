set = vim.bo
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true
vim.g.mason = { 'roslyn', 'netcoredbg' }
vim.g.ts = { 'c_sharp', 'jsonnet' }

-- Set ; to end line
vim.keymap.set(
  'n',
  '<leader>;',
  '<esc>mzA;<esc>`z',
  { noremap = true, silent = true }
)

-- Parse dotnet/msbuild diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f(%l\,%c): %t%*[^:]: %m,%f(%l\,%c): %m]]
