-- -> Miramare <-
local utils = require('utils')
local cmd = vim.cmd

if vim.fn.has("termguicolors") == 1 then
  vim.o.t_8f = "[[38;2;%lu;%lu;%lum"
  vim.o.t_8b = "[[48;2;%lu;%lu;%lum"
  vim.o.termguicolors = true
end

--[[ vim.g.miramare_cursor = 'purple'
vim.g.miramare_enable_italic = 1
vim.g.miramare_enable_italic_string = 0
vim.g.miramare_disable_italic_comment = 1
vim.g.miramare_transparent_background = 1
cmd 'colorscheme miramare' ]]

vim.g.sonokai_style = 'atlantis'
vim.g.sonokai_enable_italic = 1
vim.g.sonokai_disable_italic_comment = 1
vim.g.sonokai_cursor = 'green'
vim.g.sonokai_transparent_background = 1
vim.g.sonokai_current_word = 'bold'
cmd 'colorscheme sonokai'

-- cmd 'colorscheme kikwis'

-- vim.g.clap_theme = 'miramare'


--[[ vim.api.nvim_exec([[
" Make background transparent for many things
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
hi! LineNr ctermfg=NONE guibg=NONE
hi! SignColumn ctermfg=NONE guibg=NONE
hi! StatusLine guifg=NONE guibg=NONE
hi! StatusLineNC guifg=NONE guibg=NONE
" Try to hide vertical split and end of buffer symbol
hi! VertSplit gui=NONE guifg=NONE guibg=NONE cterm=NONE
hi! EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE ]]
-- ]], true)
