---@type lsp.config
return {
  cmd = { 'ltex-ls-plus' },
  filetypes = { 'tex', 'bib', 'markdown', 'org', 'rst', 'gitcommit', 'norg' },
  root_markers = { '.git' },
  settings = {
    ltex = {
      language = 'en-US',
      -- Parent dir holding per-language n-gram subdirs (en/, es/) for false-friend detection.
      additionalRules = {
        languageModel = vim.fn.expand('~/Documents/Models/'),
      },
    },
  },
  -- ltex checks one language per document. Toggle en-US <-> es-ES at runtime.
  -- Per-document override also works via magic comment, e.g. in markdown:
  --   <!-- ltex: language=es-ES -->
  on_attach = function(client)
    local langs = { es = 'es-ES', us = 'en-US' }
    vim.api.nvim_create_user_command('LtexLang', function(opts)
      local lang = langs[opts.args]
        or (client.settings.ltex.language == 'en-US' and 'es-ES' or 'en-US')
      client.settings.ltex.language = lang
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
