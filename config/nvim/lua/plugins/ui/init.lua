local utils = require "utils"
return {
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "LazyFile",
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- {
  --   "echasnovski/mini.tabline",
  --   -- Agregar keys
  --   keys = { { "<leader>ts", [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]] } },
  --   init = utils.setup "mini.tabline",
  -- },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/which-key.nvim",
    event = "LazyFile",
    opts = {
      -- window = { position = "top" },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "…",
      },
      spelling = { enabled = false, suggestions = 20 },
    },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = "LazyFile",
    opts = {
      render = "background", -- or 'foreground' or 'first_column'
      enable_tailwind = false,
    },
  },
  {
    "chentoast/marks.nvim",
    name = "marks",
    event = "LazyFile",
    config = utils.fn.setup("marks", {
      default_mappings = true,
      builtin_marks = { ".", "<", ">", "^" },
      cyclic = true,
      force_write_shada = false,
      refresh_interval = 250,
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    }),
  },
  -- {
  --   "ashfinal/qfview.nvim",
  --   event = "UIEnter",
  --   config = true,
  -- },
  {

    "yorickpeterse/nvim-pqf",
    event = "UIEnter",
    config = function()
      local icons = utils.static.icons.diagnostics
      require("pqf").setup {
        signs = {
          error = { text = icons.DiagnosticSignError, hl = "DiagnosticSignError" },
          warning = { text = icons.DiagnosticSignWarn, hl = "DiagnosticSignWarn" },
          info = { text = icons.DiagnosticSignInfo, hl = "DiagnosticSignInfo" },
          hint = { text = icons.DiagnosticSignHint, hl = "DiagnosticSignHint" },
        },
        show_multiple_lines = true,
      }
    end,
  },
  {
    "rasulomaroff/reactive.nvim",
    event = "InsertEnter",
    config = function()
      require("reactive").setup {
        load = { "catppuccin-mocha-cursor", "catppuccin-mocha-cursorline" },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "OXY2DEV/helpview.nvim",
    ft = "help",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {},
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  },
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    config = function()
      require("csvview").setup {
        view = {
          display_mode = "border",
        },
      }
      require("csvview").toggle()
    end,
  },
}
