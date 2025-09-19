---@type lsp_config_t
return {
  filetypes = { 'lua' },
  cmd = { 'efm-langserver' },
  requires = { 'stylua', 'cat', 'head' },
  name = 'stylua',
  root_markers = { 'stylua.toml', '.stylua.toml' },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  settings = {
    languages = {
      lua = {
        {
          formatStdin = true,
          formatCanRange = true,
          -- Use `--stdin-filepath` as a workaround to make stylua respect
          -- `.stylua.toml`, see https://github.com/JohnnyMorganz/StyLua/issues/928
          formatCommand = 'stylua --stdin-filepath ./"$(cat /dev/urandom | head -c 13)" ${--indent-width:tabSize} ${--range-start:charStart} ${--range-end:charEnd} --color Never -',
        },
      },
    },
  },
}
