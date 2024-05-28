return {
  {
    event = "InsertEnter",
    "m4xshen/autoclose.nvim",
    config = true,
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
  {
    "preservim/vim-pencil",
    cmd = {
      "Pencil",
      "TogglePencil",
      "SoftPencil",
      "HardPencil",
    },
    init = function()
      vim.g["pencil#wrapModeDefault"] = "soft"
      vim.g["pencil#autoformat"] = 1
      vim.g["pencil#textwidth"] = 80
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has "nvim-0.10.0" == 1,
  },
}
