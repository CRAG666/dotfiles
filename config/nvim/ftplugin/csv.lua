local key = require "utils.keymap"

vim.opt_local.list = true
vim.opt_local.number = true
vim.opt_local.wrap = false
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

-- Moverse al campo siguiente en la fila (al siguiente delimitador de coma)
key.map("n", "<leader>cl", "/\\v,\\s*<CR>cgn")

-- Moverse al campo anterior en la fila (al anterior delimitador de coma)
key.map("n", "<leader>ch", "?\\v,\\s*<CR>cgn")

-- Moverse abajo en la misma columna en la fila siguiente
key.map("n", "<leader>cj", [[j0/\v([^,]*){\=col(".") - 1},<CR>cgn]])

-- Moverse arriba en la misma columna en la fila anterior
key.map("n", "<leader>ck", [[k0/\v([^,]*){\=col(".") - 1},<CR>cgn]])
