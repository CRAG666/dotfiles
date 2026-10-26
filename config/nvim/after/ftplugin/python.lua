local utils = require('utils')
require('utils.ftplugin')(
  {
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = -1,
    expandtab = true,
    autoindent = true,
    smartindent = false,
    textwidth = 0,
    wrap = false,
    spell = false,
    formatoptions = vim.bo.formatoptions:gsub('t', ''),
  },
  'setlocal errorformat< colorcolumn< | silent! iunabbrev <buffer> true | silent! iunabbrev <buffer> ture | silent! iunabbrev <buffer> false | silent! iunabbrev <buffer> flase'
)

---Autocorrect `orig` to `correction` in normal zone
---@param orig string
---@param correction string
local function autocorrect_normalzone(orig, correction)
  vim.keymap.set('ia', orig, function()
    if utils.ts.is_active() then
      return utils.ts.find_node({ 'comment', 'string' }) and orig or correction
    end
    if utils.syn.is_active() then
      return utils.syn.find_group({ 'Comment', 'String' }) and orig
        or correction
    end
    return orig
  end, { buffer = true, expr = true })
end

-- Autocorrect lower-cased and misspelled booleans
autocorrect_normalzone('true', 'True')
autocorrect_normalzone('ture', 'True')
autocorrect_normalzone('false', 'False')
autocorrect_normalzone('flase', 'False')

-- Black formatter use a line width of 88 by default
if vim.wo.cc:match('^[0-9]+$') and tonumber(vim.wo.cc) < 89 then
  vim.wo.cc = '89'
end

vim.g.ts = { 'python', 'requirements' }

-- Parse python tracebacks (code_runner quickfix mode)
vim.bo.errorformat = [[%C %.%#,%A  File "%f"\, line %l%.%#,%Z%m]]
