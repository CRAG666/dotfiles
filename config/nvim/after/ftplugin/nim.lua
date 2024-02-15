local utils = require "utils"

local nimls = {
  name = "nim_langserver",
  cmd = { "nimlangserver" },
  settings = {
    nim = {
      nimsuggestPath = "usr/bin/",
    },
  },
  -- root_dir = utils.get_root_dir { ".git" },
  -- single_file_support = true,
}
require("config.lsp").setup(nimls)
