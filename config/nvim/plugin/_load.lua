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

-- winbar
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufNewFile" }, {
  once = true,
  group = vim.api.nvim_create_augroup("WinBarSetup", {}),
  callback = function()
    local winbar = require "ui.winbar"
    local api = require "ui.winbar.api"
    local utils = require "ui.winbar.utils"
    winbar.setup()

    -- vim.keymap.set('n', '<Leader>;', api.pick)
    -- vim.keymap.set('n', '[C', api.goto_context_start)
    -- vim.keymap.set('n', ']C', api.select_next_context)

    ---Set WinBar & WinBarNC background to Normal background
    ---@return nil
    local function clear_winbar_bg()
      ---@param name string
      ---@return nil
      local function _clear_bg(name)
        local hl = utils.hl.get(0, {
          name = name,
          winhl_link = false,
        })
        if hl.bg or hl.ctermbg then
          hl.bg = nil
          hl.ctermbg = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end

      _clear_bg "WinBar"
      _clear_bg "WinBarNC"
    end

    clear_winbar_bg()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("WinBarHlClearBg", {}),
      callback = clear_winbar_bg,
    })
    return true
  end,
})
