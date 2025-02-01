return {
  {
    'rstcruzo/http.nvim',
    config = function()
      require('http-nvim').setup()
    end,
    build = { ':TSUpdate http2', ':Http update_grammar_queries' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
  },
}
