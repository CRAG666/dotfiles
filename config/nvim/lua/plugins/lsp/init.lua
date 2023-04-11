return {
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    config = true,
  },
  "folke/neodev.nvim",
  "jose-elias-alvarez/null-ls.nvim",
  "Decodetalkers/csharpls-extended-lsp.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",

  {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = true,
    enabled = false,
  },
  {
    "VidocqH/lsp-lens.nvim",
    cmd = {
      "LspLensOn",
      "LspLensOff",
      "LspLensToggle",
    },
    config = true,
  },
}
