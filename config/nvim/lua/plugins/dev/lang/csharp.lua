return {
  { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
  -- { "Decodetalkers/csharpls-extended-lsp.nvim", lazy = true },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'c_sharp' })
      end
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, 'csharp-language-server')
      table.insert(opts.ensure_installed, 'omnisharp')
    end,
  },
}
