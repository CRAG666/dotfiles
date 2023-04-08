local utils = require "utils"
local prefix = "<leader>n"
local keys = {
  { prefix .. "c", desc = "Comment Class" },
  { prefix .. "f", desc = "Comment Function" },
  { prefix .. "i", desc = "Comment File" },
  { prefix .. "t", desc = "Comment type" },
}

function setup()
  local neogen = require "neogen"
  neogen.setup {
    enabled = true,
    languages = {
      lua = {
        template = {
          annotation_convention = "emmylua", -- for a full list of annotation_conventions, see supported-languages below,
        },
      },
      cs = {
        template = {
          annotation_convention = "xmldoc",
        },
      },
      python = {
        template = {
          annotation_convention = "google_docstrings",
        },
      },
      typescript = {
        template = {
          annotation_convention = "jsdoc",
        },
      },
    },
  }

  local maps = {
    "class",
    "func",
    "file",
    "type",
  }
  for i, map in ipairs(M.maps) do
    utils.map("n", map[1], function()
      neogen.generate { type = maps[i] }
    end)
  end
end

return {
  {
    "danymat/neogen",
    keys = keys,
    config = setup,
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
}
