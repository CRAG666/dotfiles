-- winbar
vim.api.nvim_create_autocmd('FileType', {
  once = true,
  group = vim.api.nvim_create_augroup('WinBarSetup', {}),
  callback = function()
    if vim.g.loaded_winbar ~= nil then
      return
    end

    local winbar = require('ui.winbar')
    local api = require('ui.winbar.api')
    winbar.setup({ bar = { hover = false } })

    -- stylua: ignore start
    vim.keymap.set('n', '<Leader>w', api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[w', api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', ']w', api.select_next_context, { desc = 'Select next context' })
    -- stylua: ignore end
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

-- Lsp servers
local disable_clients = {
  'csharp_ls',
  'texlab',
  'nimls',
  'v_analyzer',
}
require('config.lsp').setup(disable_clients)
require('config.lsp.grammar').setup()
