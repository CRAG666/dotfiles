return {
  {
    "williamboman/mason.nvim",
    config = true,
  },
  { "folke/neodev.nvim", ft = "lua" },
  { "b0o/SchemaStore.nvim", ft = "json" },
  "Decodetalkers/csharpls-extended-lsp.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",

  {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    -- config = true,
    config = function()
      require("lsp_lines").setup()
    end,
    -- enabled = false,
  },
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    opts = function()
      local nls = require "null-ls"
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt,
          nls.builtins.code_actions.refactoring,
        },
      }
    end,
  },
}
