local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

local M = {}
function M.setup()
  local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  end
  vim.opt.rtp:prepend(lazypath)
  require("config.lazy").setup()
  require("lazy").setup {
    spec = {
      { import = "plugins.general" },
      { import = "plugins.ui" },
      { import = "plugins.dev" },
      { import = "plugins.dev.lang" },
      { import = "plugins.modes" },
    },
    install = { missing = true, colorscheme = { "catppuccin" } },
    dev = { path = "~/Git/" },
    defaults = { lazy = false, version = nil },
    -- checker = { enabled = true },
    change_detection = {
      notify = false,
    },
    performance = {
      cache = {
        enabled = true,
        path = vim.fn.stdpath "cache" .. "/lazy/cache",
        disable_events = { "UIEnter", "BufReadPre" },
        ttl = 3600 * 24 * 2,
      },
      rtp = {
        disabled_plugins = {
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "netrwFileHandlers",
          "gzip",
          "matchit",
          "matchparen",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
          "zip",
          "tar",
          "getscript",
          "getscriptPlugin",
          "vimball",
          "vimballPlugin",
          "2html_plugin",
          "logipat",
          "rrhelper",
          "spellfile_plugin",
          "tutor_mode_plugin",
          "remote_plugins",
          "shada_plugin",
        },
      },
    },
  }
end

return M
