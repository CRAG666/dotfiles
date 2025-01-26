-- winbar
vim.api.nvim_create_autocmd('FileType', {
  once = true,
  group = vim.api.nvim_create_augroup('WinBarSetup', {}),
  callback = function()
    local winbar = require('ui.winbar')
    local api = require('ui.winbar.api')
    winbar.setup({ bar = { hover = false } })

    -- stylua: ignore start
    vim.keymap.set('n', '<Leader>;', api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', api.select_next_context, { desc = 'Select next context' })
    -- stylua: ignore end
    return true
  end,
})

---Load ui elements e.g. tabline, statusline, statuscolumn
---@param name string
local function load_ui(name)
  local loaded_flag = 'loaded_' .. name
  if vim.g[loaded_flag] ~= nil then
    return
  end
  vim.g[loaded_flag] = true
  vim.opt[name] = string.format("%%!v:lua.require'ui.%s'()", name)
end

load_ui('tabline')
load_ui('statusline')
load_ui('statuscolumn')

-- z
vim.api.nvim_create_autocmd({ 'UIEnter', 'CmdlineEnter', 'CmdUndefined' }, {
  group = vim.api.nvim_create_augroup('ZSetup', {}),
  desc = 'Init z plugin.',
  once = true,
  callback = function()
    vim.schedule(function()
      local z = require('modules.z')
      z.setup()
      vim.keymap.set('n', '<Leader>z', z.select, {
        desc = 'Chagne cwd using z',
      })
    end)
    return true
  end,
})
