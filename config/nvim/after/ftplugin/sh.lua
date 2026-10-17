require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
}, 'setlocal errorformat<')

vim.treesitter.language.register('bash', 'zsh')
vim.g.mason = { 'bash-language-server', 'shfmt', 'shellcheck' }
vim.g.ts = { 'bash', 'zsh' }

-- Parse bash/zsh diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f: line %l: %m,%f:%l: %m]]
