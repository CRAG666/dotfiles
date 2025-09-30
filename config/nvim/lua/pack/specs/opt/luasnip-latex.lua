return {
  src = 'https://github.com/iurimateus/luasnip-latex-snippets.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/L3MON4D3/LuaSnip',
        data = { optional = false },
      },
    },
    events = {
      event = 'Filetype',
      pattern = 'tex',
    },
    postload = function()
      require('luasnip-latex-snippets').setup({ use_treesitter = true })
    end,
  },
}
