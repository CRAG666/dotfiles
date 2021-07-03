local utils = require('utils')

require('code_runner').setup({})
utils.map('n', '<leader>R', ':RunCode<CR>', opts)
utils.map('n', '<leader>r', ':FRunCode<CR>', opts)
