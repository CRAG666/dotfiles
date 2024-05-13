return {
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find "Windows")
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "lukas-reineke/cmp-rg",
      "jc-doyle/cmp-pandoc-references",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<S-Tab>"] = {
            ["c"] = function()
              if tabout.get_jump_pos(-1) then
                tabout.jump(-1)
                return
              end
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end,
            ["i"] = function(fallback)
              if luasnip.locally_jumpable(-1) then
                local prev = luasnip.jump_destination(-1)
                local _, snip_dest_end = prev:get_buf_position()
                snip_dest_end[1] = snip_dest_end[1] + 1 -- (1, 0) indexed
                local tabout_dest = tabout.get_jump_pos(-1)
                if not jump_to_closer(snip_dest_end, tabout_dest, -1) then
                  fallback()
                end
              else
                fallback()
              end
            end,
          },
          ["<Tab>"] = {
            ["c"] = function()
              if tabout.get_jump_pos(1) then
                tabout.jump(1)
                return
              end
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
            ["i"] = function(fallback)
              if luasnip.expandable() then
                luasnip.expand()
              elseif luasnip.locally_jumpable(1) then
                local buf = vim.api.nvim_get_current_buf()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local current = luasnip.session.current_nodes[buf]
                if node_has_length(current) then
                  if
                    current.next_choice
                    or cursor_at_end_of_range({
                      current:get_buf_position(),
                    }, cursor)
                  then
                    luasnip.jump(1)
                  else
                    fallback()
                  end
                else -- node has zero length
                  local parent = node_find_parent(current)
                  local range = parent and { parent:get_buf_position() }
                  local tabout_dest = tabout.get_jump_pos(1)
                  if tabout_dest and range and in_range(range, tabout_dest) then
                    tabout.jump(1)
                  else
                    luasnip.jump(1)
                  end
                end
              else
                fallback()
              end
            end,
          },
          ["<C-p>"] = {
            ["c"] = cmp.mapping.select_prev_item(),
            ["i"] = function()
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.choice_active() then
                luasnip.change_choice(-1)
              else
                cmp.complete()
              end
            end,
          },
          ["<C-n>"] = {
            ["c"] = cmp.mapping.select_next_item(),
            ["i"] = function()
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.choice_active() then
                luasnip.change_choice(1)
              else
                cmp.complete()
              end
            end,
          },
          ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<PageDown>"] = cmp.mapping(
            cmp.mapping.select_next_item {
              count = vim.o.pumheight ~= 0 and math.ceil(vim.o.pumheight / 2) or 8,
            },
            { "i", "c" }
          ),
          ["<PageUp>"] = cmp.mapping(
            cmp.mapping.select_prev_item {
              count = vim.o.pumheight ~= 0 and math.ceil(vim.o.pumheight / 2) or 8,
            },
            { "i", "c" }
          ),
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-e>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
            else
              fallback()
            end
          end, { "i", "c" }),
          ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            },
            { "i", "c" }
          ),
        },
        -- mapping = cmp.mapping.preset.insert {
        --   ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        --   ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        --   ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        --   ["<C-f>"] = cmp.mapping.scroll_docs(4),
        --   ["<C-y>"] = cmp.mapping.complete(),
        --   ["<C-e>"] = cmp.mapping.abort(),
        --   ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        --   ["<S-CR>"] = cmp.mapping.confirm {
        --     behavior = cmp.ConfirmBehavior.Replace,
        --     select = true,
        --   }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        --   ["<C-CR>"] = function(fallback)
        --     cmp.abort()
        --     fallback()
        --   end,
        -- },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "codeium" },
          { name = "luasnip", max_item_count = 3 },
          { name = "path" },
          { name = "rg" },
          { name = "pandoc_references" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, item)
            local icons = require("utils.static.icons").kinds
            if icons[item.kind] then
              item.menu = "    (" .. (item.kind or "") .. ")"
              item.kind = " " .. icons[item.kind] .. " "
            end
            local max_width = 80
            if max_width ~= 0 and #item.abbr > max_width then
              item.abbr = string.sub(item.abbr, 1, max_width - 1) .. ""
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require("cmp").setup(opts)
      require("codeium").setup()
    end,
  },
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = { "tex", "bib" },
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip-latex-snippets").setup { use_treesitter = true }
      require("luasnip").config.setup { enable_autosnippets = true }
    end,
  },
}
