return {
  {
    "Wansmer/treesj",
    keys = {
      {
        "<leader><leader>t",
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle Join Line",
      },
      {
        "<leader><leader>s",
        function()
          require("treesj").split()
        end,
        desc = "Toggle Join Line",
      },
      {
        "<leader><leader>j",
        function()
          require("treesj").join()
        end,
        desc = "Toggle Join Line",
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup {
        use_default_keymaps = false,
      }
    end,
  },
  { "wellle/targets.vim", event = "CursorMoved" },
  { "chaoren/vim-wordmotion", event = "CursorMoved" },
  {
    "kylechui/nvim-surround",
    keys = { { "cs" }, { "ds" }, { "ys" } },
    config = true,
  },
  -- Tim Pope docet
  { "tpope/vim-repeat", event = "CursorMoved" },
}
