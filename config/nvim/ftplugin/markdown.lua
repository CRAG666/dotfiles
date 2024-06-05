vim.bo.textwidth = 98

require("config.lsp.grammar").setup()
require("config.lsp").setup {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  root_patterns = { ".marksman.toml", "build.sh" },
}
