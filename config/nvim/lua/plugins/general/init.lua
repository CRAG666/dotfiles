return {
  {
    event = "InsertEnter",
    "m4xshen/autoclose.nvim",
    config = true,
  },
  {
    "Wansmer/treesj",
    keys = {
      {
        "<leader>j",
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle Join Line",
      },
      {
        "<leader>S",
        function()
          require("treesj").split()
        end,
        desc = "Toggle Join Line",
      },
      {
        "<leader>J",
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
  {
    "wellle/targets.vim",
    keys = {
      { "ci" },
      { "di" },
      { "yi" },
      { "cI" },
      { "dI" },
      { "yI" },
      { "ca" },
      { "da" },
      { "ya" },
      { "cA" },
      { "dA" },
      { "yA" },
    },
  },
  {
    "chaoren/vim-wordmotion",
    keys = {
      { "w" },
      { "W" },
      { "b" },
      { "B" },
      { "e" },
      { "E" },
      { "ge" },
      { "gE" },
      { "caw" },
      { "caW" },
      { "ciw" },
      { "ciW" },
      { "daw" },
      { "daW" },
      { "diw" },
      { "diW" },
      { "yaw" },
      { "daW" },
      { "yiw" },
      { "yiW" },
    },
  },
  {
    "kylechui/nvim-surround",
    keys = { { "cs" }, { "ds" }, { "ys" } },
    config = true,
  },
  -- Tim Pope docet
  { "tpope/vim-repeat", keys = { "." } },
}
