local utils = require "utils"
local marksman = {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  root_dir = utils.get_root_dir { ".git", ".marksman.toml" },
}
require("config.lsp").setup(marksman)
