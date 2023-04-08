local tsserver = {
  name = "tsserver",
  cmd = { "typescript-language-server", "--stdio" },
  init_options = { hostInfo = "neovim" },
  root_dir = vim.fs.dirname(vim.fs.find({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }, { upward = true })[1])
}
require("config.lsp").setup(tsserver)
