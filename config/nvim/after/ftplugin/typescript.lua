local tsserver = {
  name = "tsserver",
  cmd = { "typescript-language-server", "--stdio" },
  init_options = { hostInfo = "neovim" },
  root_patterns = { "package.json", "tsconfig.json", "jsconfig.json" },
}
require("config.lsp").setup(tsserver)
