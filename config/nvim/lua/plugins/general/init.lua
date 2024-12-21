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
    "quentingruber/pomodoro.nvim",
    lazy = false, -- needed so the pomodoro can start at launch
    opts = {
      start_at_launch = true,
      work_duration = 25,
      break_duration = 5,
      delay_duration = 1, -- The additionnal work time you get when you delay a break
      long_break_duration = 15,
      breaks_before_long = 4,
    },
  },
}
