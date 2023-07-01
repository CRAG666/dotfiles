local utils = require "utils"
local dockerls = {
  name = "dockerls",
  cmd = { "docker-langserver", "--stdio" },
  root_dir = utils.get_root_dir "Dockerfile",
  single_file_support = true,
}
require("config.lsp").setup(dockerls)
