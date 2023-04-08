-- vim.o.completeopt = "menu,menuone,noselect"
-- vim.o.completeopt = "menuone,noselect"
vim.opt.completeopt = { "menuone", "noselect", "noinsert", "preview" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }

local utils = require "utils"

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lua",
    "ray-x/cmp-treesitter",
    -- "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    { "hrsh7th/cmp-nvim-lsp" },
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "lukas-reineke/cmp-rg",
    "davidsierradz/cmp-conventionalcommits",
    { "onsails/lspkind-nvim" },
    -- "hrsh7th/cmp-calc",
    -- "f3fora/cmp-spell",
    -- "hrsh7th/cmp-emoji",
    {
      "L3MON4D3/LuaSnip",
      name = "luasnip",
      config = utils.setup "plugins.snip",
    },
    "rafamadriz/friendly-snippets",
    "honza/vim-snippets",
    "lukas-reineke/cmp-under-comparator",
    -- { "tzachar/cmp-tabnine", build = "./install.sh", enabled = true },
  },
  config = function()
    local source_mapping = {
      nvim_lsp = "[Lsp]",
      luasnip = "[Snip]",
      buffer = "[Buffer]",
      nvim_lua = "[Lua]",
      treesitter = "[Tree]",
      path = "[Path]",
      rg = "[Rg]",
      nvim_lsp_signature_help = "[Sig]",
      -- cmp_tabnine = "[TNine]",
    }

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
    end

    local types = require "cmp.types"
    local compare = require "cmp.config.compare"
    local lspkind = require "lspkind"
    require("luasnip.loaders.from_vscode").lazy_load()

    local cmp = require "cmp"
    local luasnip = require "luasnip"

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
          luasnip.lsp_expand(args.body)
        end,
      },
      sources = {
        { name = "nvim_lsp", max_item_count = 7 },
        { name = "nvim_lsp_signature_help", max_item_count = 5 },
        { name = "luasnip", max_item_count = 5 },
        -- { name = "cmp_tabnine" },
        { name = "treesitter", max_item_count = 5 },
        { name = "rg", max_item_count = 5 },
        { name = "buffer", max_item_count = 5 },
        { name = "nvim_lua" },
        { name = "path" },
        { name = "crates" },
        -- { name = "spell" },
        -- { name = "emoji" },
        -- { name = "calc" },
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
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format { mode = "symbol_text", maxwidth = 40 }(entry, vim_item)
          local source = entry.source.name
          local menu = source_mapping[source]
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. strings[1] .. " "
          kind.menu = menu
          -- if source == "cmp_tabnine" then
          --   if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
          --     menu = entry.completion_item.data.detail .. " " .. menu
          --   end
          --   kind.kind = "  "
          -- end
          if source == "nvim_lsp" then
            kind.dup = 0
          end
          return kind
        end,
      },
      mapping = {
        ["<Up>"] = cmp.mapping.select_prev_item(select_opts),
        ["<Down>"] = cmp.mapping.select_next_item(select_opts),

        ["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
        ["<C-n>"] = cmp.mapping.select_next_item(select_opts),

        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(5),

        ["<C-e>"] = cmp.mapping.abort(),
        -- ["<CR>"] = cmp.mapping.confirm { select = false },
        ["<CR>"] = cmp.mapping {
          i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
          c = function(fallback)
            if cmp.visible() then
              cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
            else
              fallback()
            end
          end,
        },

        ["<C-d>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-b>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --   local col = vim.fn.col "." - 1
        --
        --   if cmp.visible() then
        --     cmp.select_next_item(select_opts)
        --   elseif col == 0 or vim.fn.getline("."):sub(col, col):match "%s" then
        --     fallback()
        --   else
        --     cmp.complete()
        --   end
        -- end, { "i", "s" }),

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

        -- ["<S-Tab>"] = cmp.mapping(function(fallback)
        --   if cmp.visible() then
        --     cmp.select_prev_item(select_opts)
        --   else
        --     fallback()
        --   end
        -- end, { "i", "s" }),

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
    }

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

    -- Auto pairs
    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
  end,
}
