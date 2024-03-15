local utils = require "utils.keymap"
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
  vim.opt_local.spell = true
  vim.opt_local.spelllang = language
  init(language)
end
local M = {}
function M.setup()
  utils.map("n", "<leader>sg", function()
    vim.ui.select({ "es", "en" }, {
      prompt = "Select preview mode:",
    }, function(opt, _)
      if opt then
        setltex(opt)
      else
        local warn = require("utils.notify").warn
        warn("Lang not valid", "Lang")
      end
    end)
  end, { desc = "[S]elect [G]rammar check" })

  vim.opt_local.spell = true
  vim.opt_local.spelllang = "es"
  vim.schedule(function()
    init "es"
  end)
end

return M
