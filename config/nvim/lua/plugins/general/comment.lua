return {
  "numToStr/Comment.nvim",
  keys = { { "gcc" }, { "gco" }, { "gcO" }, { "gcA" }, { "gbc" }, { "gc", mode = "v" }, { "gb", mode = "v" } },
  config = function()
    require("Comment").setup {
      pre_hook = function()
        return vim.bo.commentstring
      end,
    }
  end,
}
