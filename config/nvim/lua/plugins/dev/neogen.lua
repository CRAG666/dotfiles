local prefix = "<leader>n"
return {
  "danymat/neogen",
  keys = {
    {
      prefix .. "c",
      function()
        require("neogen").generate { type = "class" }
      end,
      desc = "Comment Class",
    },
    {
      prefix .. "f",
      function()
        require("neogen").generate { type = "func" }
      end,
      desc = "Comment Function",
    },
    {
      prefix .. "i",
      function()
        require("neogen").generate { type = "file" }
      end,
      desc = "Comment File",
    },
    {
      prefix .. "t",
      function()
        require("neogen").generate { type = "type" }
      end,
      desc = "Comment type",
    },
  },
  opts = {
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
  },
  dependencies = "nvim-treesitter/nvim-treesitter",
}
