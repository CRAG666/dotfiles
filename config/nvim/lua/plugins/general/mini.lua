local utils = require "utils"
return {
  "echasnovski/mini.move",
  name = "mini.move",
  keys = {
    { mode = { "n", "v" }, "<C-h>" },
    { mode = { "n", "v" }, "<C-l>" },
    { mode = { "n", "v" }, "<C-j>" },
    { mode = { "n", "v" }, "<C-k>" },
  },
  config = utils.setup("mini.move", {
    mappings = {
      left = "<C-h>",
      right = "<C-l>",
      down = "<C-j>",
      up = "<C-k>",
      line_left = "<C-h>",
      line_right = "<C-l>",
      line_down = "<C-j>",
      line_up = "<C-k>",
    },
  }),
}
