local setup = require("utils").setup
return {
  -- {
  --   "williamboman/mason.nvim",
  --   config = true,
  -- },
  { "folke/neodev.nvim", ft = "lua" },
  { "b0o/SchemaStore.nvim", ft = "json" },
  { "Decodetalkers/csharpls-extended-lsp.nvim", ft = "cs" },
  { "Hoffs/omnisharp-extended-lsp.nvim", ft = "cs" },
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    config = setup "lsp-lens",
  },
  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPost",
    opts = function()
      local nls = require "null-ls"
      return {
        -- root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt,
          nls.builtins.code_actions.refactoring,
        },
      }
    end,
  },
}
