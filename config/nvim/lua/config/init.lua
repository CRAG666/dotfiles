require('config.treesitter')
require('config.colorizer')
require('config.autopairs')
require('config.gitstatussigns')
require('config.tabline')
require('config.telescope')
require('config.floatTerm')
require('config.lsp')
require('config.todohi')
require('config.codeRunner')
-- require('config.devicon')
require('neoscroll').setup()
require('commented').setup({
	comment_padding = " ",
	keybindings = {n = "gc", v = "gc", nl = "gcc"},
	set_keybindings = true
})
