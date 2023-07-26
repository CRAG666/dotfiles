local set = vim.opt

set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.cinoptions = ":0g0(0s"

local ccls = {
  name = "clangd",
  cmd = { "clangd" },
  single_file_support = true,
}
require("config.lsp").setup(ccls)
