local marksman = {
  name = "marksman",
  cmd = { "marksman", "server" },
  single_file_suppor = true,
  -- root_dir = vim.fs.dirname(vim.fs.find({".git", ".marksman.toml"}, { upward = true })[1]),
}
require("config.lsp").setup(marksman)
