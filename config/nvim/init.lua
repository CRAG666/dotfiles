--   __
--  / ()  _        |\ o  _,
-- |     / \_/|/|  |/ | / |
--  \___/\_/  | |_/|_/|/\/|/
--                 |)    (|

vim.loader.enable()
-- Define leader key
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.schedule(function()
  require "config.defaults"
  require "config.keymappings"
end)
require "config.autocmds"

require("config.lazy").setup()
