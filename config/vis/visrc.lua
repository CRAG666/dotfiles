-- Prevent loading lua files from the current directory, same reason as in
-- nvim's init.lua: a local `foo.lua` would shadow modules named `foo`
package.path = package.path:gsub('%./%?%.lua;?', '')

require('vis')

require('core.opts')
require('core.ft')
require('core.ftplugin')
require('core.keymaps')
require('core.autocmds')
require('core.comment')
require('core.pairs')
require('core.colorizer')
require('core.pick')
require('core.git')
require('core.run')
require('core.z')
require('core.statusline')
require('core.format')
require('core.pack')
require('core.lsp')
