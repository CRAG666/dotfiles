local stopwords = {} ---@type table<string, string>
for lang, words in pairs({
  ['es-ES'] = 'el la los las de del que y en un una por para con es se al como pero su',
  ['en-US'] = 'the of and to in is that for it with as on this are by was not or be an',
}) do
  for word in words:gmatch('%a+') do
    stopwords[word] = lang
  end
end

---Language with the most stopwords in the first lines of the buffer, nil
---while there are too few words to tell
---@param bufnr integer
---@return string?
local function detect_language(bufnr)
  local hits = { ['es-ES'] = 0, ['en-US'] = 0 }
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
    for word in line:lower():gmatch('%a+') do
      local lang = stopwords[word]
      if lang then
        hits[lang] = hits[lang] + 1
      end
    end
  end
  if hits['es-ES'] + hits['en-US'] >= 5 then
    return hits['es-ES'] > hits['en-US'] and 'es-ES' or 'en-US'
  end
end

---@type lsp.config
return {
  cmd = { 'ltex-ls-plus' },
  filetypes = {
    'tex',
    'bib',
    'markdown',
    'org',
    'rst',
    'gitcommit',
    'norg',
    'typst',
  },
  root_markers = { '.git' },
  -- ltex skips documents whose language id is not in `ltex.enabled`, and
  -- knows these filetypes under other ids
  get_language_id = function(_, filetype)
    local ids = {
      tex = 'latex',
      bib = 'bibtex',
      rst = 'restructuredtext',
      norg = 'neorg',
    }
    return ids[filetype] or filetype
  end,
  settings = {
    ltex = {
      enabled = {
        'latex',
        'bibtex',
        'markdown',
        'org',
        'restructuredtext',
        'gitcommit',
        'neorg',
        'typst',
      },
      -- The default 'fine' writes every check to stderr, i.e. to the LSP log
      ['ltex-ls'] = { logLevel = 'warning' },
      -- Fallback until a document has enough words to detect its language
      language = 'en-US',
      -- Parent dir holding per-language n-gram subdirs (en/, es/) for
      -- confusion-pair detection (their/there).
      additionalRules = {
        languageModel = vim.fn.expand('~/Documents/Models/'),
      },
    },
  },
  handlers = {
    -- ltex requests its settings scoped to the document before every check,
    -- answer with the language detected for that buffer
    ['workspace/configuration'] = function(_, params, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      return vim.tbl_map(function(item)
        local bufnr = vim.uri_to_bufnr(item.scopeUri)
        local lang = vim.b[bufnr].ltex_language or detect_language(bufnr)
        vim.b[bufnr].ltex_language = lang
        return vim.tbl_extend(
          'force',
          client.settings.ltex,
          { language = lang }
        )
      end, params.items)
    end,
  },
  -- Override the detected language of a buffer, toggling en-US <-> es-ES.
  -- Magic comments still win, e.g. in markdown:
  --   <!-- ltex: language=es-ES -->
  on_attach = function(client, bufnr)
    local langs = { es = 'es-ES', us = 'en-US' }
    vim.api.nvim_buf_create_user_command(bufnr, 'LtexLang', function(opts)
      local current = vim.b[bufnr].ltex_language
        or client.settings.ltex.language
      local lang = langs[opts.args]
        or (current == 'en-US' and 'es-ES' or 'en-US')
      vim.b[bufnr].ltex_language = lang
      -- ltex re-requests the settings of every open document
      client:notify(
        'workspace/didChangeConfiguration',
        { settings = client.settings }
      )
      vim.notify('[ltex] language = ' .. lang)
    end, {
      nargs = '?',
      complete = function()
        return { 'es', 'us' }
      end,
    })
  end,
}
