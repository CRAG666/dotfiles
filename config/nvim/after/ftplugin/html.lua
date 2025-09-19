-- Add custom tags for wxml files to indent them correctly
if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':e') == 'wxml' then
  vim.b.html_indent_inctags = 'view'
end

vim.bo.commentstring = '<!-- %s -->'
