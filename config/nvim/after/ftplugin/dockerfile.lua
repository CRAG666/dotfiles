local dockerls = {
  name = "dockerls",
  cmd = { "docker-langserver", "--stdio" },
  root_dir = vim.fs.dirname(vim.fs.find("Dockerfile", { upward = true })[1]),
  single_file_support = true
}
require("config.lsp").setup(dockerls)
