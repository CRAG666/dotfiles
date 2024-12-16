vim.bo.textwidth = 98
vim.bo.sw = 4
vim.bo.cindent = false
vim.bo.smartindent = false
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.bo.commentstring = "<!-- %s -->"
require("config.lsp.grammar").setup()
require("config.lsp").setup {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  root_patterns = { ".marksman.toml", "build.sh" },
}
