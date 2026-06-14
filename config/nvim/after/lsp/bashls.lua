---@type lsp.config
return {
  filetypes = { 'sh' },
  cmd = {
    'bash-language-server',
    'start',
  },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
      shfmt = {
        keepPadding = true,
      },
    },
  },
}
