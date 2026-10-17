-- Add custom tags for wxml files to indent them correctly
if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':e') == 'wxml' then
  vim.b.html_indent_inctags = 'view'
end

require('utils.ftplugin')({
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = -1,
  expandtab = true,
  textwidth = 0,
  wrap = false,
  spell = false,
  commentstring = '<!-- %s -->',
}, 'unlet! b:html_indent_inctags')
vim.g.ts = { 'html', 'css', 'scss' }
