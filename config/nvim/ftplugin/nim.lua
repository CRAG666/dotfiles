local nimls = {
  name = "nim_langserver",
  cmd = { "nimlangserver" },
  settings = {
    nim = {
      nimsuggestPath = "usr/bin/",
    },
  },
  -- single_file_support = true,
}
require("config.lsp").setup(nimls)
