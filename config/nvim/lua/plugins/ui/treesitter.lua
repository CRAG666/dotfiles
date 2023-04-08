local function setup()
  -- local theme = require("catppuccin.palettes").get_palette()
  -- local colors = vim.tbl_values(theme)
  -- local colors = {
  --   theme.rosewater,
  --   theme.flamingo,
  --   theme.peach,
  --   theme.maroon,
  --   theme.mauve,
  --   theme.yellow,
  --   theme.pink,
  --   theme.teal,
  --   theme.sky,
  --   theme.lavender,
  --   theme.sapphire,
  --   theme.blue,
  --   theme.green,
  --   theme.red,
  -- }

  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "arduino",
      "bash",
      "c",
      "c_sharp",
      "cmake",
      "comment",
      "cpp",
      "css",
      "dart",
      "diff",
      "dockerfile",
      "elixir",
      "fennel",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "graphql",
      "help",
      "html",
      "http",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "json5",
      "jsonc",
      "kotlin",
      "latex",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "php",
      "python",
      "query",
      "rasi",
      "regex",
      "rust",
      "scss",
      "sql",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      use_languagetree = true,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "gni",
        scope_incremental = "gns",
        node_decremental = "gnd",
      },
    },
    indent = { enable = false },
    yati = {
      enable = true,
      default_lazy = false,
      default_fallback = "auto",
    },
    -- matchup = {
    --   enable = true,
    -- },
    -- nvim-treesitter-textobjects
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },

    endwise = {
      enable = true,
    },
    -- autotag
    autotag = {
      enable = true,
    },
    -- context_commentstring
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
  }
end

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "BufReadPost",
  config = setup,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "RRethy/nvim-treesitter-endwise",
    "yioneko/nvim-yati",
    "windwp/nvim-ts-autotag",
  },
}
