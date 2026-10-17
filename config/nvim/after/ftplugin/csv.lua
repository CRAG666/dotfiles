require('utils.ftplugin')({
  list = false,
  number = true,
  wrap = false,
  spell = false,
  foldmethod = 'manual',
  textwidth = 0,
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = -1,
  expandtab = true,
})
vim.g.ts = { 'csv' }

if vim.b.bigfile or vim.env.NVIM_NO3RD then
  return
end

if not package.loaded.csvview then
  vim.pack.add({ 'https://github.com/hat0uma/csvview.nvim' })
end

require('csvview').enable(0, { view = { display_mode = 'border' } })
vim.b.undo_ftplugin = vim.b.undo_ftplugin
  .. [[ | call luaeval("require('csvview').disable(0)")]]
