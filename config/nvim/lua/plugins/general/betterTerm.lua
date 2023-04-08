local utils = require "utils"
local current = 2
local modes = { "n", "t" }
return {
  "CRAG666/betterTerm.nvim",
  dev = true,
  keys = {
    {
      "<leader>e",
      function()
        require("betterTerm").send(require("code_runner.commands").get_filetype_command(), 1)
      end,
      desc = "Run file",
    },
    {
      mode = modes,
      "<C-;>",
      function()
        require("betterTerm").open()
      end,
      desc = "Open terminal",
    },
    {
      "<leader>tt",
      function()
        require("betterTerm").select()
      end,
      mode = modes,
      desc = "Select terminal",
    },
    {
      "<leader>ti",
      function()
        require("betterTerm").open(current)
        current = current + 1
      end,
      mode = modes,
      desc = "Init new terminal",
    },
  },
  config = true,
}
