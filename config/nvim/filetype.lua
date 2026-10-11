-- Single call, each `vim.filetype.add()` with patterns re-sorts all patterns
vim.filetype.add({
  extension = {
    -- Special filetypes for Weixin Mini Program
    wxss = 'css',
    wxml = 'html',
  },
  pattern = {
    ['.*/hypr/.*%.conf'] = 'hyprlang',
    ['zathurarc'] = 'zathurarc',
    ['.*%.rasi'] = 'rasi',
  },
})

-- Only load the language submodule, `vim.treesitter` pulls in the whole
-- treesitter runtime at startup
local ts_language = require('vim.treesitter.language')
ts_language.register('markdown', { 'quarto', 'vimwiki', 'codecompanion' })
ts_language.register('latex', 'tex')
ts_language.register('bibtex', 'bib')
