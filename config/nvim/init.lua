--   __
--  / ()  _        |\ o  _,
-- |     / \_/|/|  |/ | / |
--  \___/\_/  | |_/|_/|/\/|/
--                 |)    (|

vim.loader.enable()
-- Define leader key
require "config.defaults"
require "config.keymappings"
require "config.autocmds"
require("config.lazy").setup()
