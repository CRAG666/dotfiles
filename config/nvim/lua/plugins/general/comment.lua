return {
  "numToStr/Comment.nvim",
  keys = { { "gcc" }, { "gco" }, { "gcO" }, { "gcA" }, { "gbc" }, { "gc", mode = "v" }, { "gb", mode = "v" } },
  config = function()
    require("Comment").setup {
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    }
  end,
}
