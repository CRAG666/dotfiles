vim.bo.textwidth = 106
vim.opt_local.wrap = true
vim.bo.commentstring = '% %s'
vim.g.mason = {
  'texlab',
  'tex-fmt',
  'ltex-ls-plus',
  'bibtex-tidy',
}
vim.g.ts = { 'latex', 'bibtex' }
vim.b.root_markers =
  vim.list_extend({ 'main.tex' }, require('utils.fs').root_markers)
