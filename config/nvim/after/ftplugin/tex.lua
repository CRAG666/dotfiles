local utils = require "utils"

local root_files = {
  "Tectonic.toml",
  ".git",
}
root_path = utils.fs.proj_dir(vim.api.nvim_buf_get_name(0), root_files)
build_path = root_path .. "/build/default"

local texlab = {
  cmd = { "texlab" },
  root_patterns = root_files,
  settings = {
    texlab = {
      rootDirectory = nil,
      build = {
        auxDirectory = build_path, -- Editar
        logDirectory = build_path, -- Editar
        pdfDirectory = build_path, -- Editar
        executable = "tectonic",
        args = { "-X", "build", "--synctex", "-k", "--keep-logs" },
        onSave = false,
        forwardSearchAfter = false,
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
      formatterLineLength = 80,
    },
  },
}

-- require("config.lsp.grammar").setup()
require("config.lsp").setup(texlab)
