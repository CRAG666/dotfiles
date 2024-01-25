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
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
    cmd = "Neorg",
    ft = "norg",
    keys = {
      {
        neorg_leader .. "o",
        function()
          if neorg_enabled then
            vim.cmd ":Neorg return"
            neorg_enabled = false
            return
          end
          vim.cmd "Neorg workspace notes"
          neorg_enabled = true
        end,
        desc = "Toggle org notes",
      },
      {
        neorg_leader .. "th",
        ":Neorg toggle-concealer<CR>",
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
          vim.cmd "Neorg toc"
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
              icon_preset = "basic",
              icons = {
                code_block = {
                  conceal = false,
                },
                heading = {
                  icons = { "🌸", "🌼", "🏵️", "❇️", "💠", "◉" },
                },
              },
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/Documentos/Org/Notes",
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
                      neorg_leader .. "lf",
                      "core.integrations.telescope.find_linkable",
                      opts = { desc = "Find linkable" },
                    },
                    {
                      neorg_leader .. "il",
                      "core.integrations.telescope.insert_link",
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
          ["core.summary"] = {},
          ["core.export"] = {},
          ["core.integrations.telescope"] = {},
          ["core.ui.calendar"] = {},
        },
      }
    end,
  },
}
