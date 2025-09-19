local utils = require('utils')

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

-- Don't auto-wrap in source code
vim.opt_local.formatoptions:remove('t')
