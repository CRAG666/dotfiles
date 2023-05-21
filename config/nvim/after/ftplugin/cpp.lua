local ccls = {
  name = "clangd",
  cmd = { "clangd" },
  single_file_support = true,
}
require("config.lsp").setup(ccls)
