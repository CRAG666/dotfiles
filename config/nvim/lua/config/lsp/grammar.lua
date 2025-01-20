local utils = require "utils.keymap"
local M = {}
M.current_client_id = nil -- Variable para rastrear el cliente actual

local supported_filetypes = {
  "bib",
  "context",
  "gitcommit",
  "html",
  "markdown",
  "org",
  "norg",
  "pandoc",
  "plaintex",
  "quarto",
  "mail",
  "mdx",
  "rmd",
  "rnoweb",
  "rst",
  "tex",
  "text",
  "typst",
  "xhtml",
}

local language_id_mapping = {
  bib = "bibtex",
  pandoc = "markdown",
  plaintex = "tex",
  rnoweb = "rsweave",
  rst = "restructuredtext",
  tex = "latex",
  text = "plaintext",
}

local function get_language_id(_, filetype)
  return language_id_mapping[filetype] or filetype
end

local function init(language)
  -- Cerrar cliente LSP existente si hay uno
  if M.current_client_id then
    local client = vim.lsp.get_client_by_id(M.current_client_id)
    if client then
      client.stop()
    end
  end

  return require("config.lsp").setup {
    name = "ltex_plus",
    cmd = { "ltex-ls-plus" },
    single_file_support = true,
    get_language_id = get_language_id,
    settings = {
      ltex = {
        enabled = supported_filetypes,
        language = language,
        checkFrequency = "save",
        additionalRules = {
          enablePickyRules = false,
          motherTongue = language,
          languageModel = vim.fn.expand("~/Documentos/Models/" .. language),
        },
      },
    },
  }
end

local function setltex(language)
  vim.opt_local.spell = true
  vim.opt_local.spelllang = language
  return init(language)
end

local function create_keybind()
  utils.map("n", "<leader>sg", function()
    vim.ui.select({ "es", "en" }, {
      prompt = "Select grammar check language:",
    }, function(opt, _)
      if opt then
        M.current_client_id = setltex(opt)
      else
        local warn = require("utils.notify").warn
        warn("Lang not valid", "Lang")
      end
    end)
  end, { desc = "[S]elect [G]rammar check", buffer = 0 }) -- buffer = 0 hace que el keybind sea local al buffer actual
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = supported_filetypes,
    callback = vim.schedule_wrap(function()
      M.current_client_id = setltex "es"
      create_keybind()
    end),
  })
end

return M
