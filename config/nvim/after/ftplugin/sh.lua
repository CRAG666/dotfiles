vim.treesitter.language.register('bash', 'zsh')
vim.g.mason = { 'bash-language-server', 'shfmt', 'shellcheck' }
vim.g.ts = { 'bash', 'zsh' }

-- Parse bash/zsh diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f: line %l: %m,%f:%l: %m]]
