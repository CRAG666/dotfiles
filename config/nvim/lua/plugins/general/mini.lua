local utils = require "utils.fn"
return {
  {
    "echasnovski/mini.move",
    name = "mini.move",
    keys = {
      { mode = { "n", "v" }, "<A-h>" },
      { mode = { "n", "v" }, "<A-l>" },
      { mode = { "n", "v" }, "<A-j>" },
      { mode = { "n", "v" }, "<A-k>" },
    },
    config = utils.setup("mini.move", {
      mappings = {
        left = "<A-h>",
        right = "<A-l>",
        down = "<A-j>",
        up = "<A-k>",
        line_left = "<A-h>",
        line_right = "<A-l>",
        line_down = "<A-j>",
        line_up = "<A-k>",
      },
    }),
  },
  {
    "echasnovski/mini.splitjoin",
    version = false,
    keys = { { "gS" } },
    config = utils.setup "mini.splitjoin",
  },
  {
    "echasnovski/mini.ai",
    version = false,
    keys = {
      { "ci" },
      { "di" },
      { "yi" },
      { "cI" },
      { "dI" },
      { "yI" },
      { "ca" },
      { "da" },
      { "ya" },
      { "cA" },
      { "dA" },
      { "yA" },
    },
    config = utils.setup "mini.ai",
  },
}
