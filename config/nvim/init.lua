-- Prevent loading lua files from the current directory.
-- E.g. when cwd is `lua/pack/specs/opt/`, `require('nvim-web-devicons')` will
-- load the local `nvim-web-devicons.lua` config file instead of the plugin
-- itself. This will confuse plugins that depends on `nvim-web-devicons`.
-- Subsequent calls to nvim-web-devicons' function may fail.
-- Remove the current directory from `package.path` to avoid errors.
package.path = package.path:gsub('%./%?%.lua;?', '')

-- require('vim._core.ui2').enable({
--   enable = true,
--   msg = {
--     targets = 'cmd',
--     cmd = {
--       height = 0.5,
--     },
--     dialog = {
--       height = 0.5, -- Maximum height.
--     },
--     msg = { -- Options related to msg window.
--       height = 0.5, -- Maximum height.
--       timeout = 4000, -- Time a message is visible in the message window.
--     },
--     pager = { -- Options related to message window.
--       height = 1, -- Maximum height.
--     },
--   },
-- })

-- Enable faster lua loader using byte-compilation
-- https://github.com/neovim/neovim/commit/2257ade3dc2daab5ee12d27807c0b3bcf103cd29
vim.loader.enable()

require('core.opts')
require('core.keymaps')
require('core.autocmds')
require('core.pack')

local load = require('utils.load')

load.on_events('FileType', 'core.treesitter')
load.on_events('DiagnosticChanged', 'core.diagnostic')
load.on_events('FileType', 'core.lsp')
require('core.format')
do
  local f = io.open(vim.fn.expand('~/.config/eyes/mode'), 'r')
  local mode = f and (f:read('*l') or 'light') or 'light'
  if f then f:close() end
  vim.o.background = (mode == 'dark') and 'dark' or 'light'
end
vim.cmd.colorscheme('eyes')

-- Learning Keybindings
--  ctrl+wv  Split buffer vertical
--  ctrl+ws  Split buffer horizontal
-- g;  Jump to the next change.
-- g,  Jump to the previous change
-- gUw  Uppercase until end of word (u for lower, ~ to toggle)
-- gUiw  Uppercase entire word (u for lower, ~ to toggle)
-- gUU  Uppercase entire line
