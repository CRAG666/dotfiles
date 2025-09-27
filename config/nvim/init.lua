-- Prevent loading lua files from the current directory.
-- E.g. when cwd is `lua/pack/specs/opt/`, `require('nvim-web-devicons')` will
-- load the local `nvim-web-devicons.lua` config file instead of the plugin
-- itself. This will confuse plugins that depends on `nvim-web-devicons`.
-- Subsequent calls to nvim-web-devicons' function may fail.
-- Remove the current directory from `package.path` to avoid errors.
package.path = package.path:gsub('%./%?%.lua;?', '')

-- Disable validation for speed
---@diagnostic disable-next-line: duplicate-set-field
vim.validate = function() end

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
load.on_events({ 'FileType', 'LspAttach' }, 'core.lsp')
require('core.format')
