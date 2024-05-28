vim.treesitter.language.register("bash", "zsh")
require("config.lsp").setup {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.zsh|.command)",
    },
  },
  single_file_support = true,
}
