-- statuscolumn
vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("StatusColumn", {}),
  desc = "Init statuscolumn plugin.",
  once = true,
  callback = function()
    require("ui.statuscolumn").setup()
    return true
  end,
})

vim.go.statusline = [[%!v:lua.require'ui.statusline'.render()]]

-- tabline
vim.go.tabline = [[%!v:lua.require'ui.tabline'.get()]]

-- winbar
vim.api.nvim_create_autocmd("FileType", {
  once = true,
  group = vim.api.nvim_create_augroup("WinBarSetup", {}),
  callback = function()
    local winbar = require "ui.winbar"
    local api = require "ui.winbar.api"
    winbar.setup { bar = { hover = false } }

    -- stylua: ignore start
    -- vim.keymap.set('n', '<Leader>;', api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', api.select_next_context, { desc = 'Select next context' })
    -- stylua: ignore end
    return true
  end,
})
