vim.bo.textwidth = 100
vim.bo.commentstring = "% %s"
local utils = require "utils"

local root_files = {
  "Tectonic.toml",
  ".git",
  "references.bib",
}
root_path = vim.fs.root(0, root_files)
build_path = root_path .. "/build/default"

local texlab = {
  cmd = { "texlab" },
  root_patterns = root_files,
  settings = {
    texlab = {
      rootDirectory = root_path,
      build = {
        auxDirectory = build_path,
        logDirectory = build_path,
        pdfDirectory = build_path,
        executable = "tectonic",
        args = { "-X", "watch", "-x", "'build --synctex -k --keep-logs'" },
        onSave = false,
        forwardSearchAfter = true,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
        onSave = false,
      },
      auxDirectory = ".",
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
      diagnosticsDelay = 300,
      latexFormatter = "latexindent",
      latexindent = {
        ["local"] = nil,
        modifyLineBreaks = false,
      },
      bibtexFormatter = "texlab",
      formatterLineLength = 100,
    },
  },
}

require("config.lsp.grammar").setup()
require("config.lsp").setup(texlab)
