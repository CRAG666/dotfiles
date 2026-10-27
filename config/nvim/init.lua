-- Prevent loading lua files from the current directory.
-- E.g. when cwd is `lua/pack/specs/opt/`, `require('nvim-web-devicons')` will
-- load the local `nvim-web-devicons.lua` config file instead of the plugin
-- itself. This will confuse plugins that depends on `nvim-web-devicons`.
-- Subsequent calls to nvim-web-devicons' function may fail.
-- Remove the current directory from `package.path` to avoid errors.
package.path = package.path:gsub('%./%?%.lua;?', '')

-- Enable faster lua loader using byte-compilation
-- https://github.com/neovim/neovim/commit/2257ade3dc2daab5ee12d27807c0b3bcf103cd29
vim.loader.enable()

require('core.opts')
require('core.keymaps')
require('core.autocmds')
require('core.pack')

local load = require('utils.load')

load.on_events(load.ft_event, 'core.treesitter')
load.on_events('DiagnosticChanged', 'core.diagnostic')
-- Start language servers after the first redraw instead of blocking it,
-- `vim.lsp.enable()` only attaches to existing buffers after `VimEnter`
load.on_events(load.ft_event, 'core.lsp', function()
  local function setup()
    vim.schedule(function()
      require('core.lsp')
    end)
  end
  if vim.v.vim_did_enter == 1 then
    setup()
  else
    vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = setup })
  end
end)
require('core.format')
vim.cmd.colorscheme('eyes')

-- Learning Keybindings
--  ctrl+wv  Split buffer vertical
--  ctrl+ws  Split buffer horizontal
-- g;  Jump to the next change.
-- g,  Jump to the previous change
-- gUw  Uppercase until end of word (u for lower, ~ to toggle)
-- gUiw  Uppercase entire word (u for lower, ~ to toggle)
-- gUU  Uppercase entire line
