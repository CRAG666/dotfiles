require('plugins.ui')
require('plugins.dev')
require('plugins.general')
require('plugins.modes')

local key = require('utils.keymap')

key.map('n', '<leader>pu', vim.pack.update, { desc = 'Update Plugins' })
key.map('n', '<leader>pi', vim.pack.get, { desc = 'Plugins Info' })
