return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<C-I>",
          clear_suggestion = "<C-CR>",
          accept_word = "<C-J>",
        },
      }
    end,
  },
  -- add blink.compat
  -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "0.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "jc-doyle/cmp-pandoc-references",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      { "saghen/blink.compat", version = "*", opts = { impersonate_nvim_cmp = true } },
      "mikavilpas/blink-ripgrep.nvim",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      highlight = {
        use_nvim_cmp_as_default = false,
      },
      windows = {
        documentation = {
          auto_show = true,
        },
      },
      keymap = { preset = "super-tab" },
      sources = {
        completion = {
          enabled_providers = function(ctx)
            local node = vim.treesitter.get_node()
            local providers = { "lsp", "path", "snippets", "buffer", "luasnip", "ripgrep", "supermaven" }
            if vim.bo.filetype == "tex" then
              table.insert(providers, "pandoc_references")
              return providers
            else
              return providers
            end
          end,
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        signature = {
          enabled = true,
        },
        providers = {
          luasnip = {
            name = "luasnip",
            module = "blink.compat.source",

            score_offset = -3,

            opts = {
              use_show_condition = false,
              show_autosnippets = true,
            },
          },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            -- the options below are optional, some default values are shown
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              -- For many options, see `rg --help` for an exact description of
              -- the values that ripgrep expects.

              -- the minimum length of the current word to start searching
              -- (if the word is shorter than this, the search will not start)
              prefix_min_len = 3,

              -- The number of lines to show around each match in the preview window
              context_size = 5,

              -- The maximum file size that ripgrep should include in its search.
              -- Useful when your project contains large files that might cause
              -- performance issues.
              -- Examples: "1024" (bytes by default), "200K", "1M", "1G"
              max_filesize = "1M",
            },
          },
          pandoc_references = {
            name = "pandoc_references",
            module = "blink.compat.source",
            score_offset = -3,
          },
          supermaven = {
            name = "supermaven",
            module = "blink.compat.source",
            score_offset = 1,
          },
        },
      },
    },
  },
}
