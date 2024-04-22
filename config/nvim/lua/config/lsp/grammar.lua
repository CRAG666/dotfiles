local utils = require "utils.keymap"

local language_id_mapping = {
  bib = "bibtex",
  plaintex = "tex",
  rnoweb = "rsweave",
  rst = "restructuredtext",
  tex = "latex",
  pandoc = "markdown",
  text = "plaintext",
}

local filetypes = {
  "bib",
  "gitcommit",
  "markdown",
  "org",
  "plaintex",
  "rst",
  "rnoweb",
  "tex",
  "pandoc",
  "quarto",
  "rmd",
  "context",
  "html",
  "xhtml",
  "mail",
  "text",
}

local function get_language_id(_, filetype)
  local language_id = language_id_mapping[filetype]
  if language_id then
    return language_id
  else
    return filetype
  end
end
local enabled_ids = {}
do
  local enabled_keys = {}
  for _, ft in ipairs(filetypes) do
    local id = get_language_id({}, ft)
    if not enabled_keys[id] then
      enabled_keys[id] = true
      table.insert(enabled_ids, id)
    end
  end
end

local function init(language)
  require("config.lsp").setup {
    name = "ltex",
    cmd = { "ltex-ls" },
    get_language_id = get_language_id,
    single_file_support = true,
    settings = {
      ltex = {
        enabled = enabled_ids,
        language = language,
        additionalRules = {
          enablePickyRules = true,
          motherTongue = language,
        },
        checkFrequency = "save",
        setenceCacheSize = 20000,
        trace = { server = "off" },
      },
    },
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
  init "es"
end

return M
