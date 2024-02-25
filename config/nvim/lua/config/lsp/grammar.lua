utils = require "utils"
local function init(language)
  require("config.lsp").setup {
    name = "ltex",
    cmd = { "ltex-ls" },
    flags = { debounce_text_changes = 300 },
    settings = {
      ltex = {
        enabled = {
          "bibtex",
          "context",
          "gitcommit",
          "html",
          "latex",
          "markdown",
          "org",
          "quarto",
          "restructuredtext",
          "rmd",
          "rsweave",
          "tex",
          "xhtml",
        },
        language = language,
        checkFrequency = "save",
        setenceCacheSize = 2000,
        trace = { server = "verbose" },
      },
    },
    single_file_support = true,
  }
end

local function setltex(language)
  vim.cmd("setlocal spell! spelllang=" .. language)
  init(language)
end
local M = {}
function M.setup()
  utils.map("n", "<leader>ge", function()
    setltex "es"
  end, { desc = "Set grammar check es" })

  utils.map("n", "<leader>gi", function()
    setltex "en"
  end, { desc = "Set grammar check en" })
end

vim.cmd "setlocal spell! spelllang=es"
vim.schedule(function()
  init "es"
end)
return M
