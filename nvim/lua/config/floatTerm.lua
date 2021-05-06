local utils = require('utils')

require'FTerm'.setup({
    dimensions  = {
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5
    },
    border = 'single' -- or 'double'
})

-- Closer to the metal
utils.map('n', '<A-d>', '<CMD>lua require("FTerm").toggle()<CR>', opts)
utils.map('t', '<A-d>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', opts)

