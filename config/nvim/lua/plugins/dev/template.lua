-- with lazy.nvim

return {
  "nvimdev/template.nvim",
  cmd = { "Template", "TemProject" },
  config = function()
    require("template").setup {
      temp_dir = "~/Plantillas",
      author = "Diego Crag",
      email = "dcrag@pm.me",
    }
  end,
}
