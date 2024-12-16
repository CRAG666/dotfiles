vim.bo.textwidth = 100
vim.bo.commentstring = "% %s"

local root_files = {
  "Tectonic.toml",
  ".git",
}

root_path = vim.fs.root(0, root_files)
build_path = "build/default"

local texlab = {
  cmd = { "texlab" },
  root_patterns = root_files,
  settings = {
    texlab = {
      rootDirectory = root_path,
      build = {
        auxDirectory = build_path,
        -- logDirectory = build_path,
        -- pdfDirectory = build_path,
        filename = "default.pdf",
        executable = "tectonic",
        args = { "-X", "build", "--synctex", "-k", "--keep-logs" },
        onSave = false,
        forwardSearchAfter = true,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
        onSave = false,
      },
      auxDirectory = build_path,
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
