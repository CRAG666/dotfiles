--   __
--  / ()  _        |\ o  _,
-- |     / \_/|/|  |/ | / |
--  \___/\_/  | |_/|_/|/\/|/
--                 |)    (|

-- Define leader key
-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.maplocalleader = " "
vim.g.mapleader = " "
vim.g.cmp_enable = true
require("plugins").setup()
