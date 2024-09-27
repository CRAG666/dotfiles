vim.bo.textwidth = 98
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

require("config.lsp.grammar").setup()
require("config.lsp").setup {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  root_patterns = { ".marksman.toml", "build.sh" },
}
