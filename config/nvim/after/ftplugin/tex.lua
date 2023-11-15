local utils = require "utils"

local root_files = {
  "Tectonic.toml",
  ".git",
}
local texlab = {
  name = "texlab",
  cmd = { "texlab" },
  root_dir = utils.get_root_dir(root_files),
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        executable = "tectonic",
        args = { "%f", "--synctex", "--keep-logs", "--keep-intermediates" },
        forwardSearchAfter = false,
        onSave = false,
      },
      chktex = {
        onEdit = true,
        onOpenAndSave = true,
      },
      diagnosticsDelay = 100,
      formatterLineLength = 80,
      forwardSearch = {
        args = {},
      },
      latexFormatter = "texlab",
      latexindent = {
        modifyLineBreaks = true,
      },
    },
  },
  single_file_suppor = true,
}
require("config.lsp").setup(texlab)
