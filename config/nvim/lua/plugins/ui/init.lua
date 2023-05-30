local utils = require "utils"
return {
  { "tamton-aquib/flirt.nvim" },
  { "sitiom/nvim-numbertoggle", event = { "BufEnter", "WinEnter" } },
  {
    "echasnovski/mini.indentscope",
    -- event = "CursorMoved",
    event = "BufReadPre",
    config = utils.setup "mini.indentscope",
  },

  {
    "echasnovski/mini.tabline",
    -- Agregar keys
    keys = { { "<leader>ts", [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]] } },
    init = utils.setup "mini.tabline",
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "folke/which-key.nvim",
    event = "UIEnter",
    opts = {
      -- window = { position = "top" },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "…",
      },
      spelling = { enabled = true, suggestions = 20 },
    },
  },
  {
    "jinh0/eyeliner.nvim",
    event = "UIEnter",
    opts = {
      bold = true, -- Default: false
      underline = true, -- Default: false
    },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPost",
    opts = {
      render = "background", -- or 'foreground' or 'first_column'
      enable_tailwind = false,
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = { "BufEnter", "BufNewFile" },
    -- event = "BufReadPost",
    opts = {
      highlight = {
        keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
      },
    },
  },
  {
    "chentoast/marks.nvim",
    name = "marks",
    event = { "BufEnter", "BufNewFile" },
    config = utils.setup("marks", {
      default_mappings = true,
      builtin_marks = { ".", "<", ">", "^" },
      cyclic = true,
      force_write_shada = false,
      refresh_interval = 250,
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    }),
  },
  {
    "gen740/SmoothCursor.nvim",
    lazy = false,
    opts = { fancy = { enable = true } },
    -- enabled = false,
  },
}
