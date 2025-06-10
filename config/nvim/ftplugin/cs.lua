set = vim.bo
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

-- Set ; to end line
vim.keymap.set("n", "<leader>;", "<esc>mzA;<esc>`z", { noremap = true, silent = true })
