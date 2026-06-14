vim.bo.cindent = false
vim.bo.smartindent = false
vim.bo.commentstring = '# %s'

---Don't join first line of list item with previous lines when yanking with
---joined paragraphs
---@param line string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function vim.b.should_join_line(line)
  return line ~= ''
    and not line:match('^%s*[-*]%s+')
    and not line:match('^%s*%d+%.%s+')
end
