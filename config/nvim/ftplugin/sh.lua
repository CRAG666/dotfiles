local bashls = {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
  single_file_support = true,
}
require("config.lsp").setup(bashls)
