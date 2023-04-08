set = vim.bo
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

local util = require("lspconfig").util
local root_dir = function(file, _)
  if file:sub(-#".csx") == ".csx" then
    return util.path.dirname(file)
  end
  return util.root_pattern "*.sln"(file) or util.root_pattern "*.csproj"(file)
end

local pid = vim.fn.getpid()

-- local csharp_ls = {
--   name = "csharp_ls",
--   cmd = { "csharp-ls" },
--   -- root_dir = vim.fs.dirname(vim.fs.find({'Prueba.sln', 'Prueba.csproj'}, { upward = true })[1]),
--   init_options = { AutomaticWorkspaceInit = true },
--   handlers = {
--     ["textDocument/definition"] = require("csharpls_extended").handler,
--   },
--   root_dir = root_dir(vim.fn.expand "%"),
-- }
-- require("config.lsp").setup(csharp_ls)

local omnisharp = {
  handlers = {
    ["textDocument/definition"] = require("omnisharp_extended").handler,
  },
  -- cmd = { "dotnet", "/usr/lib/omnisharp-roslyn/OmniSharp.dll", "--languageserver", "--hostPID", tostring(pid) },
  cmd = { "/usr/bin/omnisharp", "--languageserver", "--hostPID", tostring(pid) },
  enable_editorconfig_support = true,
  enable_ms_build_load_projects_on_demand = false,
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
  sdk_include_prereleases = false,
  analyze_open_documents_only = true,
  root_dir = root_dir(vim.fn.expand "%"),
}
require("config.lsp").setup(omnisharp)
