local set = vim.opt

set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.cinoptions = ":0g0(0s"

local utils = require "utils"

local root_files = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.txt",
  "configure.ac",
  ".git",
}

local ccls = {
  name = "clangd",
  cmd = { "clangd" },
  root_dir = utils.get_root_dir(root_files),
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  single_file_support = true,
}
require("config.lsp").setup(ccls)
