local neorg_leader = "\\"
return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  ft = "norg",
  cmd = "Neorg",
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
