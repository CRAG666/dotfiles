---@type lsp.config
return {
  filetypes = { 'lua' },
  cmd = { 'efm-langserver' },
  requires = { 'luacheck' },
  name = 'luacheck',
  root_markers = { '.luacheckrc' },
  settings = {
    languages = {
      lua = {
        {
          lintSource = 'luacheck',
          -- Use `--filename` tell luacheck the source file of stdin and apply
          -- per-files rules defined in `.luacheckrc` and per-path std
          -- overrides:
          -- - https://luacheck.readthedocs.io/en/stable/config.html#per-file-and-per-path-overrides
          -- - https://luacheck.readthedocs.io/en/stable/config.html#default-per-path-std-overrides
          -- - https://luacheck.readthedocs.io/en/stable/cli.html#stable-interface-for-editor-plugins-and-tools
          lintCommand = 'luacheck --codes --no-color --quiet --filename ${INPUT} -',
          lintFormats = { '%.%#:%l:%c: (%t%n) %m' },
          lintAfterOpen = true,
          lintStdin = true,
          lintIgnoreExitCode = true,
        },
      },
    },
  },
}
