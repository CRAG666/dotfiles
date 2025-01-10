return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<C-I>",
        clear_suggestion = "<C-CR>",
        accept_word = "<C-J>",
      },
      ignore_filetypes = { "bigfile" },
    },
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "*",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "jc-doyle/cmp-pandoc-references",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
          {
            "iurimateus/luasnip-latex-snippets.nvim",
            ft = { "tex", "bib" },
            config = function()
              require("luasnip-latex-snippets").setup { use_treesitter = true }
            end,
          },
        },
        config = function()
          local ls = require "luasnip"
          local ls_types = require "luasnip.util.types"
          local static = require "utils.static"

          ls.setup {
            keep_roots = true,
            link_roots = true,
            exit_roots = false,
            link_children = true,
            region_check_events = "CursorMoved,CursorMovedI",
            delete_check_events = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            store_selection_keys = "<Tab>",
            ext_opts = {
              [ls_types.choiceNode] = {
                active = {
                  virt_text = { { static.icons.ArrowLeftRight, "Number" } },
                },
              },
              [ls_types.insertNode] = {
                unvisited = {
                  virt_text = { { static.boxes.single.vt, "NonText" } },
                  virt_text_pos = "inline",
                },
              },
              [ls_types.exitNode] = {
                unvisited = {
                  virt_text = { { static.boxes.single.vt, "NonText" } },
                  virt_text_pos = "inline",
                },
              },
            },
          }

          -- Unlink current snippet on leaving insert/selection mode
          -- https://github.com/L3MON4D3/LuaSnip/issues/258#issuecomment-1011938524
          vim.api.nvim_create_autocmd("ModeChanged", {
            desc = "Unlink current snippet on leaving insert/selection mode.",
            group = vim.api.nvim_create_augroup("LuaSnipModeChanged", {}),
            callback = function(info)
              local mode = vim.v.event.new_mode
              local omode = vim.v.event.old_mode
              if
                (omode == "s" and mode == "n" or omode == "i")
                and ls.session.current_nodes[info.buf]
                and not ls.session.jump_active
              then
                ls.unlink_current()
              end
            end,
          })

          ---Load snippets for a given filetype
          ---@param ft string
          ---@return nil
          local function load_snippets(ft)
            local ok, snip_groups = pcall(require, "snippets." .. ft)
            if ok and type(snip_groups) == "table" then
              for _, snip_group in pairs(snip_groups) do
                ls.add_snippets(ft, snip_group.snip or snip_group, snip_group.opts or {})
              end
            end
          end

          -- Lazy-load snippets based on filetype
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            load_snippets(vim.bo[buf].ft)
          end
          vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("LuaSnipLazyLoadSnippets", {}),
            desc = "Lazy load snippets for different filetypes.",
            callback = function(info)
              load_snippets(vim.bo[info.buf].ft)
            end,
          })
        end,
      },
      {
        "saghen/blink.compat",
        version = "*",
        opts = {},
      },
      "mikavilpas/blink-ripgrep.nvim",
      "Kaiser-Yang/blink-cmp-dictionary",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "super-tab" },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true },
        ghost_text = { enabled = false },
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1, "kind" },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  return " " .. ctx.kind_icon .. ctx.icon_gap .. " "
                end,
              },
              kind = {
                text = function(ctx)
                  return "(" .. ctx.kind .. ")"
                end,
                highlight = function(ctx)
                  return require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx) or "BlinkCmpCustomType"
                end,
              },
            },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "ripgrep", "supermaven" },
        per_filetype = {
          markdown = {
            "lsp",
            "path",
            "snippets",
            "buffer",
            "ripgrep",
            "supermaven",
            "pandoc_references",
            "dictionary",
          },
          norg = {
            "lsp",
            "path",
            "snippets",
            "buffer",
            "ripgrep",
            "supermaven",
            "dictionary",
          },
          quarto = {
            "lsp",
            "path",
            "snippets",
            "buffer",
            "ripgrep",
            "supermaven",
            "pandoc_references",
            "dictionary",
          },
          tex = {
            "lsp",
            "path",
            "snippets",
            "buffer",
            "ripgrep",
            "supermaven",
            "pandoc_references",
            "dictionary",
          },
        },
        -- cmdline = {},
        providers = {
          dictionary = {
            module = "blink-cmp-dictionary",
            name = "Dict",
          },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            score_offset = -4,
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
              max_filesize = "1G",
            },
          },
          pandoc_references = {
            name = "pandoc_references",
            module = "blink.compat.source",
            score_offset = -1,
          },
          supermaven = {
            name = "supermaven",
            module = "blink.compat.source",
            score_offset = 100,
            async = true,
          },
        },
      },
      snippets = { preset = "luasnip" },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
