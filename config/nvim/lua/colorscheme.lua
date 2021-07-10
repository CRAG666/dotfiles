-- -> Miramare <-
local utils = require('utils')
local cmd = vim.cmd

if vim.fn.has("termguicolors") == 1 then
  vim.go.t_8f = "[[38;2;%lu;%lu;%lum"
  vim.go.t_8b = "[[48;2;%lu;%lu;%lum"
  vim.go.termguicolors = true
end

-- cmd 'colorscheme blackbird'
-- cmd 'colorscheme oblivion-dark'

-- vim.g.tokyonight_transparent = true
-- cmd 'colorscheme tokyonight'

-- vim.g.kimbox_transparent_background = 1
-- cmd 'colorscheme kimbox'

-- vim.g.gruvbox_transparent = true
-- cmd 'colorscheme gruvbox-flat'

vim.g.miramare_cursor = 'purple'
vim.g.miramare_enable_italic = 1
vim.g.miramare_enable_italic_string = 0
vim.g.miramare_disable_italic_comment = 1
vim.g.miramare_transparent_background = 1
cmd 'colorscheme miramare'

-- vim.g.sonokai_style = 'atlantis'
-- vim.g.sonokai_enable_italic = 1
-- vim.g.sonokai_disable_italic_comment = 1
-- vim.g.sonokai_cursor = 'green'
-- vim.g.sonokai_transparent_background = 1
-- vim.g.sonokai_current_word = 'bold'
-- cmd 'colorscheme sonokai'
