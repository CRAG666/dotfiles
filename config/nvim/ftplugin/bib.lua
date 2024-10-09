vim.bo.textwidth = 100
vim.bo.commentstring = "% %s"
local utils = require "utils"

local root_files = {
  "references.bib",
}
local root_path = vim.fs.root(0, root_files)
local build_path = root_path .. "/build/default"

local texlab = {
  cmd = { "texlab" },
  root_patterns = root_files,
  settings = {
    texlab = {
      rootDirectory = root_path,
      bibtexFormatter = "texlab",
    },
  },
}

-- Verifica si ya existe una instancia de texlab activa
local function is_texlab_active()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == "texlab" then
      return true
    end
  end
  return false
end

-- Solo configurar texlab si no está activo
if not is_texlab_active() then
  require("config.lsp").setup(texlab)
end
