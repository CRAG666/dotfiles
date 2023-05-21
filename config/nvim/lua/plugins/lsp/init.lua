return {
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    config = true,
  },
  { "folke/neodev.nvim", ft = "lua" },
  "jose-elias-alvarez/null-ls.nvim",
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
}
