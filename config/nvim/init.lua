--   __
--  / ()  _        |\ o  _,
-- |     / \_/|/|  |/ | / |
--  \___/\_/  | |_/|_/|/\/|/
--                 |)    (|

-- Define leader key
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("plugins").setup()
