local marksman = {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  root_patterns = { ".marksman.toml" },
}
require("config.lsp.grammar").setup()
require("config.lsp").setup(marksman)
