return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    -- lazy = true,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "ray-x/cmp-treesitter",
      "lukas-reineke/cmp-rg",
      -- "davidsierradz/cmp-conventionalcommits",
      "lukas-reineke/cmp-under-comparator",
      { "tzachar/cmp-tabnine", build = "./install.sh", enabled = true },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
      -- "hrsh7th/cmp-calc",
      -- "f3fora/cmp-spell",
      -- "hrsh7th/cmp-emoji",
    },
    config = function()
      vim.opt.completeopt = { "menuone", "noselect", "noinsert", "preview" }
      vim.opt.shortmess = vim.opt.shortmess + { c = true }
      local cmp = require "cmp"
      local luasnip = require "luasnip"
      -- local neogen = require "neogen"
      local compare = require "cmp.config.compare"
      local types = require "cmp.types"
      local lspkind = require "lspkind"
      local source_mapping = {
        nvim_lsp = "[Lsp]",
        luasnip = "[Snip]",
        buffer = "[Buffer]",
        nvim_lua = "[Lua]",
        treesitter = "[Tree]",
        path = "[Path]",
        rg = "[Rg]",
        nvim_lsp_signature_help = "[Sig]",
        cmp_tabnine = "[TNine]",
        ["vim-dadbod-completion"] = "[DB]",
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

      local select_opts = { behavior = cmp.SelectBehavior.Select }

      cmp.setup {
        completion = { completeopt = "menu,menuone,noinsert", keyword_length = 1 },
        performance = { debounce = 40, throttle = 40, fetching_timeout = 300 },
        sorting = {
          priority_weight = 2,
          comparators = {
            -- require "cmp_tabnine.compare",
            compare.score,
            compare.recently_used,
            compare.offset,
            compare.exact,
            require("cmp-under-comparator").under,
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
          ["<Up>"] = cmp.mapping.select_prev_item(select_opts),
          ["<Down>"] = cmp.mapping.select_next_item(select_opts),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(5),
          ["<C-e>"] = cmp.mapping.abort(),
          -- ["<CR>"] = cmp.mapping.confirm { select = false },
          ["<CR>"] = cmp.mapping {
            i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
            -- c = function(fallback)
            --   if cmp.visible() then
            --     cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
            --   else
            --     fallback()
            --   end
            -- end,
          },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s", "c" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_opts)
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s", "c" }),
        },
        sources = {
          { name = "nvim_lsp", group_index = 1 },
          { name = "nvim_lsp_signature_help", group_index = 1 },
          { name = "luasnip", group_index = 1 },
          { name = "cmp_tabnine", group_index = 1 },
          { name = "buffer", group_index = 2 },
          { name = "path", group_index = 2 },
          { name = "treesitter", group_index = 2 },
          { name = "rg", group_index = 2 },
          { name = "nvim_lua", group_index = 2 },
          { name = "neorg", group_index = 2 },
          -- { name = "spell" },
          -- { name = "emoji" },
          -- { name = "calc" },
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
            if source == "cmp_tabnine" then
              if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
                menu = entry.completion_item.data.detail .. " " .. menu
              end
              kind.kind = "  "
            end
            local max_width = 80
            if max_width ~= 0 and #kind.abbr > max_width then
              kind.abbr = string.sub(kind.abbr, 1, max_width - 1) .. ""
            end
            kind.dup = duplicates[entry.source.name] or duplicates_default
            return kind
          end,
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

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources {
          { name = "buffer", option = { indexing_interval = 284 }, keyword_length = 1, priority = 1 },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path", keyword_length = 1, priority = 2 },
        }, {
          { name = "cmdline", keyword_length = 1, priority = 1 },
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

      -- TabNine
      local tabnine = require "cmp_tabnine.config"
      tabnine:setup {
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        snippet_placeholder = "..",
        ignored_file_types = { -- default is not to ignore
          -- uncomment to ignore in lua:
          -- lua = true
        },
      }
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "evesdropper/luasnip-latex-snippets.nvim",
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "honza/vim-snippets",
        config = function()
          require("luasnip.loaders.from_snipmate").lazy_load()

          -- One peculiarity of honza/vim-snippets is that the file with the global snippets is _.snippets, so global snippets
          -- are stored in `ls.snippets._`.
          -- We need to tell luasnip that "_" contains global snippets:
          require("luasnip").filetype_extend("all", { "_" })
        end,
      },
    },
    build = "make install_jsregexp",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    -- stylua: ignore
    -- keys = {
    --   {
    --     "<Tab>",
    --     function()
    --       return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<Tab>"
    --     end,
    --     expr = true, remap = true, silent = true, mode = "i",
    --   },
    --   { "<Tab>", function() require("luasnip").jump(1) end, mode = "s" },
    --   { "<S-Tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    -- },
    config = function(_, opts)
      require("luasnip").setup(opts)

      local snippets_folder = vim.fn.stdpath "config" .. "/lua/plugins/lsp/snippets/"
      require("luasnip.loaders.from_lua").lazy_load { paths = snippets_folder }

      vim.api.nvim_create_user_command("LuaSnipEdit", function()
        require("luasnip.loaders.from_lua").edit_snippet_files()
      end, {})
    end,
  },
  {
    "madskjeldgaard/cheeky-snippets.nvim",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cheeky = require "cheeky"
      cheeky.setup {
        langs = {
          all = true,
          lua = true,
          cpp = true,
          asm = true,
          cmake = true,
          markdown = true,
          supercollider = true,
        },
      }
    end,
  },
}
