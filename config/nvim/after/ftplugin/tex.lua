vim.bo.textwidth = 88
vim.opt_local.wrap = true
vim.bo.commentstring = '% %s'
-- LaTeX errorformat (vim-latex lineage): parses -file-line-error lines,
-- multiline "! ..." errors (Runaway argument, Emergency stop) and tracks the
-- open-file stack from the log's parens. Errors only; warnings are ignored.
vim.bo.errorformat = table.concat({
  [[%E%f:%l: %m]],
  [[%E! LaTeX %trror: %m]],
  [[%E! %m]],
  [[%Cl.%l %m]],
  [[%+C  %m.]],
  [[%+C%.%#-%.%#]],
  [[%+C%.%#[]%.%#]],
  [[%+C[]%.%#]],
  [[%+C%.%#%[{}\]%.%#]],
  [[%+C<%.%#>%.%#]],
  [[%C  %m]],
  [[%-GSee the LaTeX%m]],
  [[%-GType  H <return>%m]],
  [[%-G  ...%.%#]],
  [[%-G%.%# (C) %.%#]],
  [[%-G(see the transcript%.%#)]],
  [[%-G\s%#]],
  [[%+O(%*[^()])%r]],
  [[%+O%*[^()](%*[^()])%r]],
  [[%+P(%f%r]],
  [[%+P %\=(%f%r]],
  [[%+P%*[^()](%f%r]],
  [[%+P[%\d%[^()]%#(%f%r]],
  [[%-Q)%r]],
  [[%-Q%*[^()])%r]],
  [[%-Q[%\d%*[^()])%r]],
  [[%-G%.%#]],
}, ',')
vim.g.mason = {
  'texlab',
  'tex-fmt',
  'ltex-ls-plus',
  'bibtex-tidy',
}
vim.g.ts = { 'latex', 'bibtex' }
vim.b.root_markers =
  vim.list_extend({ 'main.tex' }, require('utils.fs').root_markers)
-- vim.cmd('VimtexView')

-- local timer = nil
-- local function sync()
--   if timer then
--     timer:stop()
--   end
--   timer = vim.defer_fn(function()
--     vim.cmd('VimtexView')
--   end, 150)
-- end
--
-- vim.keymap.set('n', 'j', function()
--   vim.cmd('normal! ' .. (vim.v.count == 0 and 'gj' or 'j'))
--   if vim.g.tectonic_enabled == true then
--     sync()
--   end
-- end, { buffer = true, silent = true })
--
-- vim.keymap.set('n', 'k', function()
--   vim.cmd('normal! ' .. (vim.v.count == 0 and 'gk' or 'k'))
--   if vim.g.tectonic_enabled == true then
--     sync()
--   end
-- end, { buffer = true, silent = true })
