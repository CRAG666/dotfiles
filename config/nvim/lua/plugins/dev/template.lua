-- with lazy.nvim

return {
  "glepnir/template.nvim",
  cmd = { "Template", "TemProject" },
  config = function()
    require("template").setup {
      temp_dir = "~/.config/nvim/template",
      author = "Diego Crag",
      email = "dcrag@pm.me",
    }
  end,
}
