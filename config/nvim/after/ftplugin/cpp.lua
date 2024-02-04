local set = vim.opt

set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.cinoptions = ":0g0(0s"

local utils = require "utils"

local root_files = {
  ".clang-format",
  ".clang-tidy",
  ".clangd",
  ".git",
  "Makefile",
  "build.ninja",
  "compile_commands.json",
  "compile_flags.txt",
  "config.h.in",
  "configure.ac",
  "configure.in",
  "meson.build",
  "meson_options.txt",
}

local ccls = {
  name = "clangd",
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  root_dir = utils.get_root_dir(root_files),

  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
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
require("config.lsp").setup(ccls, function(...)
  require("clangd_extensions.inlay_hints").setup_autocmd()
  require("clangd_extensions.inlay_hints").set_inlay_hints()
end)
