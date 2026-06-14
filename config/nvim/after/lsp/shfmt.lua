-- Shell script formatter for sh/bash/mksh
-- https://github.com/patrickvane/shfmt

---@type lsp.config
return {
  filetypes = { 'sh' },
  cmd = { 'efm-langserver' },
  requires = { 'shfmt' },
  name = 'shfmt',
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      sh = {
        {
          -- If `expandtab` is not set, use tabs for indentation, else use
          -- spaces with the same width in nvim, see `shfmt -h` and
          -- https://github.com/mattn/efm-langserver/blob/master/schema.md#2113-property-format-command
          formatCommand = 'shfmt --keep-padding --filename ${INPUT} --indent=${tabWidth} ${--indent=0:!insertSpaces} -',
          formatStdin = true,
        },
      },
    },
  },
}
