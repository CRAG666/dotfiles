local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

local M = {}
function M.setup()
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable", -- remove this if you want to bootstrap to HEAD
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup {
    spec = {
      { import = "plugins.general" },
      { import = "plugins.ui" },
      { import = "plugins.dev" },
      { import = "plugins.dev.lang" },
      { import = "plugins.modes" },
    },
    -- install = { missing = true, colorscheme = { "catppuccin" } },
    dev = { path = "~/Git/" },
    defaults = { lazy = true },
    checker = { enabled = false },
    change_detection = {
      notify = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
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
