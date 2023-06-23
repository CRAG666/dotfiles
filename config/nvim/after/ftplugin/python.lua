vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.textwidth = 0
vim.bo.autoindent = true
vim.bo.smartindent = true

--LSP

local root_files = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "pyrightconfig.json",
}

local pyright = {
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        typeCheckingMode = "on",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- "openFilesOnly" or "openFilesOnly"
        stubPath = vim.fn.stdpath "data" .. "/lazy/python-type-stubs/stubs",
      },
    },
  },
  single_file_support = true,
}

local ruff_lsp = {
  name = "ruff-lsp",
  cmd = { "ruff-lsp" },
  single_file_support = true,
  root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
  init_options = {
    settings = {
      args = { "--max-line-length=180" },
    },
  },
}
require("config.lsp").setup(pyright)
require("config.lsp").setup(ruff_lsp)
