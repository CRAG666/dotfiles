require('utils.ftplugin')({
  cindent = false,
  smartindent = false,
  commentstring = '# %s',
  textwidth = 0,
  wrap = true,
  linebreak = true,
  breakindent = true,
  spell = true,
}, 'unlet! b:should_join_line')

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
