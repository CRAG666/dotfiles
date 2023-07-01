local utils = require "utils"

local tsserver = {
  name = "tsserver",
  cmd = { "typescript-language-server", "--stdio" },
  init_options = { hostInfo = "neovim" },
  root_dir = utils.get_root_dir { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
}
require("config.lsp").setup(tsserver)
