return {
  src = 'https://github.com/iurimateus/luasnip-latex-snippets.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/L3MON4D3/LuaSnip',
        data = { optional = true },
      },
    },
    events = {
      event = 'Filetype',
      pattern = 'tex',
    },
    postload = function()
      vim.schedule(function()
        require('luasnip-latex-snippets').setup({ use_treesitter = true })
      end)
    end,
  },
}
