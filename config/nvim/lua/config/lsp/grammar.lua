local utils = require('utils.keymap')
local M = {}
M.current_client_id = nil

local supported_filetypes = {
  'bib',
  'context',
  'gitcommit',
  'html',
  'markdown',
  'org',
  'norg',
  'pandoc',
  'plaintex',
  'quarto',
  'mail',
  'mdx',
  'rmd',
  'rnoweb',
  'rst',
  'tex',
  'text',
  'typst',
  'xhtml',
}

local language_id_mapping = {
  bib = 'bibtex',
  pandoc = 'markdown',
  plaintex = 'tex',
  rnoweb = 'rsweave',
  rst = 'restructuredtext',
  tex = 'latex',
  text = 'plaintext',
}

local function map_filetypes()
  local mapped_list = {}
  for _, filetype in ipairs(supported_filetypes) do
    if language_id_mapping[filetype] then
      table.insert(mapped_list, language_id_mapping[filetype])
    else
      table.insert(mapped_list, filetype)
    end
  end
  return mapped_list
end

local function setltex(language)
  vim.opt_local.spell = true
  vim.opt_local.spelllang = language
  return require('utils.lsp').start({
    name = 'ltex_plus',
    cmd = { 'ltex-ls-plus' },
    settings = {
      ltex = {
        enabled = map_filetypes(),
        language = language,
        checkFrequency = 'save',
        additionalRules = {
          enablePickyRules = false,
          languageModel = '~/Documentos/Models/',
        },
      },
    },
  })
end

local function create_keybind()
  utils.map('n', '<leader>sg', function()
    vim.ui.select({ 'es', 'en' }, {
      prompt = 'Select grammar check language:',
    }, function(opt, _)
      if opt then
        if M.current_client_id then
          local client = vim.lsp.get_client_by_id(M.current_client_id)
          if client then
            client:stop(true)
          end
        end
        vim.schedule(function()
          M.current_client_id = setltex(opt)
        end)
      else
        local warn = require('utils.notify').warn
        warn('Lang not valid', 'Lang')
      end
    end)
  end, { desc = '[S]elect [G]rammar check', buffer = 0 }) -- buffer = 0 hace que el keybind sea local al buffer actual
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = supported_filetypes,
    callback = function()
      create_keybind()
    end,
  })
end

return M
