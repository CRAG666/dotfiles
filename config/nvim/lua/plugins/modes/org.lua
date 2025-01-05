local neorg_leader = "<leader>o"
local neorg_enabled = false
-- vim.w.toc_open = false
-- vim.w.win_toc = -1
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "norg", "norg_meta" })
      end
    end,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "luarocks.nvim",
      "nvim-neorg/neorg-telescope",
      {
        "juniorsundar/neorg-extras",
        version = "*",
      },
    },
    cmd = "Neorg",
    ft = "norg",
    keys = {
      {
        neorg_leader .. "o",
        function()
          if neorg_enabled then
            vim.cmd.Neorg "return"
            neorg_enabled = false
            return
          end
          vim.cmd.Neorg.workspace "notes"
          neorg_enabled = true
        end,
        desc = "Toggle org notes",
      },
      {
        neorg_leader .. "c",
        function()
          vim.cmd.Neorg "toggle-concealer"
        end,
        desc = "Toggle highlighting org",
      },
      {
        neorg_leader .. "tt",
        function()
          -- if vim.w.toc_open then
          --   vim.api.nvim_win_close(vim.w.win_toc, false)
          --   vim.w.toc_open = false
          --   return
          -- end
          vim.cmd.Neorg "toc"
          vim.cmd "vert resize 60"
          -- vim.w.win_toc = vim.api.nvim_win_get_number(0)
          -- vim.w.toc_open = true
        end,
        desc = "Toggle highlighting org",
      },
    },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
          ["core.integrations.nvim-cmp"] = {},
          ["core.concealer"] = {
            config = {
              dim_code_blocks = { conceal = false },
              icon_preset = "basic",
              -- icon_preset = "diamond",
              icons = {
                code_block = {
                  conceal = true,
                },
                delimiter = {
                  horizontal_line = {
                    icon = "■",
                  },
                },
                -- todo = {
                --   cancelled = { icon = "🚫" },
                --   done = { icon = "✅" },
                --   undone = { icon = "🕒" },
                --   on_hold = { icon = "⏸️" },
                --   pending = { icon = "⏳" },
                --   recurring = { icon = "🔄" },
                --   uncertain = { icon = "❓" },
                --   urgent = { icon = "🚨" },
                -- },
                definition = {
                  single = { icon = "󰃃" },
                  multi_prefix = { icon = "󰉾 " },
                  multi_suffix = { icon = "󰝗 " },
                },
                list = {
                  icons = { "" },
                },
                quote = {
                  icons = { "󰇙" },
                },
                heading = {
                  icons = { "🌸 ", "🌼 ", "💠 ", "🍀 ", "🪻 ", "❁" },
                },
              },
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/Documentos/Org/Notes",
                state_art = "~/Documentos/Org/Estado_Arte/",
              },
            },
          },
          ["core.keybinds"] = {
            config = {
              neorg_leader = neorg_leader,
              hook = function(keybinds)
                keybinds.map_event_to_mode("norg", {

                  n = { -- Bind keys in normal mode
                    {
                      neorg_leader .. "fl",
                      "core.integrations.telescope.find_linkable",
                      opts = { desc = "Find linkable" },
                    },
                    {
                      neorg_leader .. "fh",
                      "core.integrations.telescope.search_headings",
                      opts = { desc = "Search headings" },
                    },
                    {
                      neorg_leader .. "fi",
                      "core.integrations.telescope.insert_link",
                      opts = { desc = "Insert link" },
                    },
                    {
                      neorg_leader .. "ff",
                      "core.integrations.telescope.insert_file_link",
                      opts = { desc = "Insert link" },
                    },
                    { "]l", "core.integrations.treesitter.next.link", opts = { desc = "Next link" } },
                    { "[l", "core.integrations.treesitter.previous.link", opts = { desc = "Previous link" } },
                  },

                  i = { -- Bind in insert mode
                    { "<C-l>", "core.integrations.telescope.insert_link", opts = { desc = "Insert link" } },
                  },
                }, {
                  silent = true,
                  noremap = true,
                })
              end,
            },
          },
          ["core.looking-glass"] = {},
          ["core.export"] = {},
          ["core.integrations.telescope"] = {},
          ["core.summary"] = {},
          ["core.ui.calendar"] = {},
          ["core.latex.renderer"] = {},
          ["external.many-mans"] = {
            config = {
              metadata_fold = true, -- If want @data property ... @end to fold
              code_fold = true, -- If want @code ... @end to fold
            },
          },
          -- OPTIONAL
          ["external.agenda"] = {},
          ["external.roam"] = {
            config = {
              fuzzy_finder = "Telescope", -- OR "Fzf" ... Defaults to "Telescope"
              fuzzy_backlinks = false, -- Set to "true" for backlinks in fuzzy finder instead of buffer
              roam_base_directory = "", -- Directory in current workspace to store roam nodes
              node_name_randomiser = false, -- Tokenise node name suffix for more randomisation
            },
          },
        },
      }
    end,
  },
}
