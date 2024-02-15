local utils = require "utils"

local v_analyzer = {
  name = "v_analyzer",
  cmd = { "v-analyzer" },
  root_dir = utils.get_root_dir { "v.mod", ".git" },
}
require("config.lsp").setup(v_analyzer)
