local dockerls = {
  name = "dockerls",
  cmd = { "docker-langserver", "--stdio" },
  root_patterns = {
    "Dockerfile",
  },
  single_file_support = true,
}
require("config.lsp").setup(dockerls)
