vim.o.concealcursor = "n"
-- vim.opt_local.concealcursor = ""
vim.o.conceallevel = 2
-- vim.opt_local.wrap = true
vim.o.textwidth = 150

require("config.lsp.grammar").setup()
