local current = 2
local modes = { "n" }
return {
  "CRAG666/betterTerm.nvim",
  dev = true,
  keys = {
    {
      mode = { "n", "t" },
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
  opts = {
    position = "bot",
    size = 15,
  },
  -- config = true,
}
