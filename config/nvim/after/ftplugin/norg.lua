vim.opt.concealcursor = 'n'
-- vim.opt_local.concealcursor = ""
vim.opt.conceallevel = 2
-- vim.opt_local.wrap = true
vim.o.textwidth = 106
vim.g.ts = { 'norg', 'norg_meta' }

local utils = require('utils.keymap')
local options = {
  Maestria = function()
    vim.cmd('Template Maestria/' .. os.date('%d-%m-%Y') .. '.norg' .. ' sa')
  end,
  Doctorado = function()
    vim.cmd('Template Doctorado/' .. os.date('%d-%m-%Y') .. '.norg' .. ' sa')
  end,
}
utils.map('n', '<leader>sa', function()
  vim.ui.select(vim.tbl_keys(options), {
    prompt = 'Stado del arte de',
  }, function(opt, _)
    if vim.tbl_get(options, opt) == nil then
      vim.notify(
        'Option not found',
        vim.log.levels.ERROR,
        { title = 'Invalid option' }
      )
      return
    end
    options[opt]()
  end)
end)
