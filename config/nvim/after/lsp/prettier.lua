local cmd = 'prettier'

local cmds = {
  'prettier_d',
  'prettierd',
  'prettier',
}

for _, c in ipairs(cmds) do
  if vim.fn.executable(c) == 1 then
    cmd = c
    break
  end
end

local prettier_lang_settings = {
  {
    formatCommand = cmd
      .. ' --stdin-filepath ${INPUT} ${--range-start=charStart} ${--range-end=charEnd} ${--tab-width=tabWidth} ${--use-tabs=!insertSpaces}',
    formatCanRange = true,
    formatStdin = true,
  },
}

---@type lsp.config
return {
  filetypes = {
    'typescript',
    'javascript',
    'typescriptreact',
    'javascriptreact',
    'jsonc',
    'json',
    'html',
    'css',
  },
  cmd = { 'efm-langserver' },
  requires = { cmd },
  name = cmd,
  root_markers = {
    {
      'prettier.config.js',
      'prettier.config.mjs',
      'prettier.config.cjs',
      '.prettierrc',
      '.prettierrc.js',
      '.prettierrc.mjs',
      '.prettierrc.cjs',
      '.prettierrc.json',
      '.prettierrc.hjson',
      '.prettierrc.json5',
      '.prettierrc.toml',
      '.prettierrc.yaml',
      '.prettierrc.yml',
    },
    { 'package.json' },
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  settings = {
    languages = {
      -- Setup all supported languages because this lsp config file
      -- is shared between all these filetypes
      typescriptreact = prettier_lang_settings,
      javascriptreact = prettier_lang_settings,
      typescript = prettier_lang_settings,
      javascript = prettier_lang_settings,
      jsonc = prettier_lang_settings,
      json = prettier_lang_settings,
      html = prettier_lang_settings,
      css = prettier_lang_settings,
    },
  },
}
