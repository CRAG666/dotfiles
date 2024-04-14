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
vim.g.modern_ui = true
require "config.defaults"
require "config.keymappings"
require "config.autocmds"
require("config.lazy").setup()
