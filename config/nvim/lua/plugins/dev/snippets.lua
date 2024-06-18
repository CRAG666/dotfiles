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
    config = function()
      local fn = vim.fn
      local ls = require "luasnip"
      local ls_types = require "luasnip.util.types"
      local static = require "utils.static"

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

      ---@return nil
      local function lazy_load_snippets()
        local snippets_path = vim.split(fn.globpath(fn.stdpath "config" .. "/lua/snippets", "*.lua"), "\n")
        -- Record filetypes of all opened buffers
        local opened_file_ftlist = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local ft = vim.bo[buf].ft
          if ft ~= "" then
            opened_file_ftlist[ft] = true
          end
        end
        local groupid = vim.api.nvim_create_augroup("LuaSnipLazyLoadSnippets", {})
        for _, path in ipairs(snippets_path) do
          local ft = fn.fnamemodify(path, ":t:r")
          -- Load snippet immediately if ft matches the filetype of any opened buffer
          if opened_file_ftlist[ft] then
            load_snippets(ft)
          else -- Otherwise, load snippet when filetype is detected
            vim.api.nvim_create_autocmd("FileType", {
              once = true,
              pattern = ft,
              group = groupid,
              callback = function()
                load_snippets(ft)
                return true
              end,
            })
          end
        end
      end
      ls.setup {
        keep_roots = true,
        link_roots = false,
        link_children = true,
        region_check_events = "CursorMoved,CursorMovedI",
        delete_check_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        ext_opts = {
          [ls_types.choiceNode] = {
            active = {
              virt_text = { { static.icons.Enum, "Number" } },
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
      lazy_load_snippets()
    end,
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
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
