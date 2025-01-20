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

-- tabline, statusline, statuscolumn
vim.go.tabline = [[%!v:lua.require'ui.tabline'()]]
vim.go.statusline = [[%!v:lua.require'ui.statusline'()]]
vim.opt.statuscolumn = [[%!v:lua.require'ui.statuscolumn'()]]

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
