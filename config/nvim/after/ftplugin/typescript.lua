vim.g.mason = {
  'typescript-language-server',
  'emmet-language-server',
  'prettierd',
  'js-debug-adapter',
}
vim.bo.commentstring = '// %s'
vim.g.ts = { 'typescript', 'javascript', 'tsx' }

-- Parse tsc + node diagnostics (code_runner quickfix mode)
vim.bo.errorformat = [[%f(%l\,%c): %t%*[^:]: %m,%*[ ]at %.%#(%f:%l:%c),%f:%l]]
