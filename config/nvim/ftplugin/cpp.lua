local set = vim.opt

set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.cinoptions = ':0g0(0s'
vim.bo.commentstring = '// %s'

-- Set ; to end line
vim.keymap.set("n", "<leader>;", "<esc>mzA;<esc>`z", { noremap = true, silent = true })
