local texlab = {
  name = "texlab",
  cmd = { "texlab" },
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        -- args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        args = { "%f" },
        -- executable = "latexmk",
        executable = "pdftex",
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
