return {
  {
    "hrsh7th/nvim-cmp",
    event = { "LspAttach", "InsertCharPre" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "ray-x/cmp-treesitter",
      "lukas-reineke/cmp-rg",
      "lukas-reineke/cmp-under-comparator",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
    },
    opts = function()
      -- vim.opt.completeopt = { "menuone", "noselect", "noinsert", "preview" }
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      vim.opt.shortmess = vim.opt.shortmess + { c = true }
      local cmp = require "cmp"
      local luasnip = require "luasnip"
      local neogen = require "neogen"
      local compare = require "cmp.config.compare"
      local types = require "cmp.types"
      local lspkind = require "lspkind"
      local source_mapping = {
        nvim_lsp = "(Lsp)",
        luasnip = "(Snip)",
        buffer = "(Buffer)",
        nvim_lua = "(Lua)",
        treesitter = "(Tree)",
        path = "(Path)",
        rg = "(Rg)",
        nvim_lsp_signature_help = "(Sig)",
        ["vim-dadbod-completion"] = "(DB)",
      }

      local duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      }

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      local check_backspace = function()
        local col = vim.fn.col "." - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
      end
      -- local select_opts = { behavior = cmp.SelectBehavior.Select }

      return {
        performance = { debounce = 40, throttle = 40, fetching_timeout = 300 },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.score,
            compare.offset,
            compare.exact,
            require("cmp-under-comparator").under,
            compare.recently_used,
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
        },
        sources = {
          { name = "nvim_lsp", group_index = 1, keyword_length = 1 },
          { name = "luasnip", group_index = 1, keyword_length = 2 },
          { name = "treesitter", group_index = 1, keyword_length = 3 },
          { name = "buffer", group_index = 2, keyword_length = 3 },
          { name = "rg", group_index = 2, keyword_length = 3 },
          { name = "path", group_index = 3 },
          { name = "nvim_lua", group_index = 3 },
          { name = "neorg", group_index = 3 },
          { name = "nvim_lsp_signature_help" },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            local kind = require("lspkind").cmp_format { mode = "symbol_text", maxwidth = 40 }(entry, item)
            local source = entry.source.name
            local menu = source_mapping[source]
            local duplicates_default = 0
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. strings[1] .. " "
            kind.menu = menu
            if source == "treesitter" then
              kind.kind = " 󰐅 "
            end
            local max_width = 80
            if max_width ~= 0 and #kind.abbr > max_width then
              kind.abbr = string.sub(kind.abbr, 1, max_width - 1) .. ""
            end
            kind.dup = duplicates[entry.source.name] or duplicates_default
            return kind
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        window = {
          completion = cmp.config.window.bordered {
            border = "none",
            side_padding = 0,
            col_offset = -3,
          },
          documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:TelescopeBorder",
          },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Auto pairs
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
    end,
  },
  -- snippets
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find "Windows")
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "iurimateus/luasnip-latex-snippets.nvim",
        ft = { "tex", "bib" },
        config = function()
          require("luasnip-latex-snippets").setup { use_treesitter = true }
        end,
      },
    },
    opts = {
      history = true,
      -- delete_check_events = "TextChanged",
      enable_autosnippets = true,
      region_check_events = "InsertEnter",
      delete_check_events = "InsertLeave",
    },
    -- stylua: ignore
    -- keys = {
    --   {
    --     "<tab>",
    --     function()
    --       return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
    --     end,
    --     expr = true, silent = true, mode = "i",
    --   },
    --   { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
    --   { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    -- },
  },
}
