local key = require('utils.keymap')

vim.pack.add({ { src = 'https://github.com/cbochs/grapple.nvim' } })

key.map('n', '<leader>m', '<cmd>Grapple toggle<cr>', { desc = '[m]ark file' })
key.map('n', "<leader>'", '<cmd>Grapple toggle_tags<cr>', { desc = 'Marked Files' })
key.map('n', '<leader>`', '<cmd>Grapple toggle_scopes<cr>', { desc = 'Grapple toggle scopes' })
key.map('n', '<leader>j', '<cmd>Grapple cycle forward<cr>', { desc = 'Grapple cycle forward' })
key.map('n', '<leader>k', '<cmd>Grapple cycle backward<cr>', { desc = 'Grapple cycle backward' })