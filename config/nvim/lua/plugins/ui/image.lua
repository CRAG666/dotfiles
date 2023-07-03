return {
  "3rd/image.nvim",
  ft = { "norg", "markdown" },
  config = function()
    require("image").setup {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          sizing_strategy = "auto",
          download_remote_images = true,
        },
      },
      max_width = 25,
      max_height = 25,
      max_width_window_percentage = nil,
      max_height_window_percentage = 25,
      kitty_method = "normal",
      kitty_tmux_write_delay = 5,
    }
  end,
}
