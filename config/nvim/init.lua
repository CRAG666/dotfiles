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

load.on_events('FileType', 'core.treesitter')
load.on_events('DiagnosticChanged', 'core.diagnostic')
load.on_events('FileType', 'core.lsp')
require('core.format')
vim.o.background = 'light'
vim.cmd.colorscheme('eyes')

-- Learning Keybindings
--  ctrl+wv  Split buffer vertical
--  ctrl+ws  Split buffer horizontal
-- g;  Jump to the next change.
-- g,  Jump to the previous change
-- gUw  Uppercase until end of word (u for lower, ~ to toggle)
-- gUiw  Uppercase entire word (u for lower, ~ to toggle)
-- gUU  Uppercase entire line
