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
    end
  },
  -- add blink.compat
  -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
  {
    'saghen/blink.cmp',
    event = "InsertEnter",
    version = '0.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      "lukas-reineke/cmp-rg",
      "jc-doyle/cmp-pandoc-references",
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      { 'saghen/blink.compat', version = '*', opts = { impersonate_nvim_cmp = true } },
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
      keymap = { preset = 'super-tab' },
      sources = {
        completion = {
          enabled_providers = function(ctx)
            local node = vim.treesitter.get_node()
            local providers = {'lsp', 'path', 'snippets', 'buffer', 'luasnip', 'rg', 'supermaven' }
            if vim.bo.filetype == 'tex' then
              table.insert(providers, 'pandoc_references')
              return providers
            else
              return providers
            end
          end
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        signature = {
            enabled = true,
        },
        providers = {
          luasnip = {
            name = 'luasnip',
            module = 'blink.compat.source',

            score_offset = -3,

            opts = {
              use_show_condition = false,
              show_autosnippets = true,
            },
          },
          rg = {
            name = 'rg',
            module = 'blink.compat.source',
            score_offset = -1,
          },
          pandoc_references = {
            name = 'pandoc_references',
            module = 'blink.compat.source',
            score_offset = -3,
          },
          supermaven = {
            name = 'supermaven',
            module = 'blink.compat.source',
            score_offset = 1,
          },
        }
      }
    }
  },
}
