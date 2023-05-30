local neorg_leader = "\\"
return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  ft = "norg",
  cmd = "Neorg",
  keys = {
    {
      "<leader><leader>o",
      ":Neorg workspace notes<cr>",
      desc = "Norg",
    },
    { neorg_leader .. "tu", desc = "Task undone" },

    { neorg_leader .. "tp", desc = "Task pending" },

    { neorg_leader .. "td", desc = "Task done" },

    { neorg_leader .. "th", desc = "Task on_hold" },

    { neorg_leader .. "tc", desc = "Task cancelled" },

    { neorg_leader .. "tr", desc = "Task recurring" },

    { neorg_leader .. "ti", desc = "Task important" },

    { neorg_leader .. "ta", desc = "Task ambiguous" },
    { neorg_leader .. "nn", desc = "New note" },

    { neorg_leader .. "lt", desc = "Toggle list type" },
    { neorg_leader .. "li", desc = "Invert list type" },
    { neorg_leader .. "mn", desc = "OrgMode" },
  },
  opts = {
    load = {
      ["core.defaults"] = {}, -- Loads default behaviour
      ["core.export"] = {}, -- Loads default behaviour
      ["core.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      },
      ["core.integrations.nvim-cmp"] = {}, -- Adds pretty icons to your documents
      ["core.integrations.telescope"] = {}, -- Adds pretty icons to your documents
      ["core.keybinds"] = {
        config = {
          neorg_leader = neorg_leader,
        },
      },
      -- ["core.concealer"] = {}, -- Adds pretty icons to your documents
      ["core.concealer"] = { config = { icon_preset = "diamond" } },
      ["core.dirman"] = { -- Manages Neorg workspaces
        config = {
          workspaces = {
            notes = "~/Documentos/Notes",
          },
        },
      },
    },
  },
  dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
}
