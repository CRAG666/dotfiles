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
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
  single_file_support = true,
}

require("config.lsp").setup(pyright)
