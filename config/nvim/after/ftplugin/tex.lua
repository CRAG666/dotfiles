vim.bo.textwidth = 88
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

local timer = nil
local function sync()
  if timer then
    timer:stop()
  end
  timer = vim.defer_fn(function()
    vim.cmd('VimtexView')
  end, 150)
end

vim.keymap.set('n', 'j', function()
  vim.cmd('normal! ' .. (vim.v.count == 0 and 'gj' or 'j'))
  sync()
end, { buffer = true, silent = true })

vim.keymap.set('n', 'k', function()
  vim.cmd('normal! ' .. (vim.v.count == 0 and 'gk' or 'k'))
  sync()
end, { buffer = true, silent = true })
