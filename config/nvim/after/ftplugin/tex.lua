local texlab = {
  name = "texlab",
  cmd = { "texlab" },
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        executable = "latexmk",
        forwardSearchAfter = false,
        onSave = false,
      },
      chktex = {
        onEdit = false,
        onOpenAndSave = false,
      },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      forwardSearch = {
        args = {},
      },
      latexFormatter = "latexindent",
      latexindent = {
        modifyLineBreaks = false,
      },
    },
  },
  single_file_suppor = true,
  -- root_dir = vim.fs.dirname(vim.fs.find({".git", ".marksman.toml"}, { upward = true })[1]),
}
require("config.lsp").setup(texlab)
