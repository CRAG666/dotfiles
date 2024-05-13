local cssls = {
  name = "cssls",
  cmd = { "vscode-css-languageserver", "--stdio" },
}
require("config.lsp").setup(cssls)
