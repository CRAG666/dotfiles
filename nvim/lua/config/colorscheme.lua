-- -> Miramare <-
local utils = require('utils')
local cmd = vim.cmd

if vim.fn.has("termguicolors") == 1 then
  vim.o.t_8f = "[[38;2;%lu;%lu;%lum"
  vim.o.t_8b = "[[48;2;%lu;%lu;%lum"
  utils.opt('o', 'termguicolors', true)
end

vim.g.miramare_enable_italic = 1
vim.g.miramare_disable_italic_comment = 1
vim.g.miramare_transparent_background = 1
cmd 'colorscheme miramare'

-- vim.g.seiya_target_groups = has('nvim') ? ['guibg'] : ['ctermbg']
-- vim.g.seiya_auto_enable=1

vim.g.clap_theme = 'miramare'

-- Themes
-- material-palenight, atelier-estuary, onedark, tomorrow-night, black-metal-dark-funeral
-- atelier-plateau, nord, black-metal-burzum, woodland, unikitty-light, irblack, circus
-- greenscreen, gruvbox-light-soft, atelier-cave, hopscotch, helios, atelier-seaside,
-- horizon-dark, tube, tomorrow, mexico-light, chalk, bespin, tomorrow-night-eighties,
-- atelier-lakeside, eighties, synth-midnight-dark, uni kitty-dark, summerfruit-dark,
-- black-metal, apathy, shapeshifter, grayscale-dark, classic-dark, one-light, atelier-dune,
-- spacemacs, solarized-light, pop, atelier-sulphurpool, solarized-dark, grayscal e-light,
-- solarflare, snazzy, atelier-dune-light, atelier-seaside-light, atlas, black-metal-khold,
-- atelier-forest, default-dark, isotope, atelier-plateau-light, railscasts, brogrammer,
-- atelier-cave-lig ht, porple, classic-light, material-lighter, codeschool, pico, gruvbox-dark-soft,
-- phd, flat, br ewer, darktooth, black-metal-nile, 3024, papercolor-light, ashes, atelier-heath,
-- gruvbox-light-medi um, atelier-savanna, ia-dark, gruvbox-light-hard, zenburn, black-metal-mayhem,
-- ocean, material-dark er, black-metal-marduk, atelier-estuary-light, icy, xcode-dusk, github, mocha,
-- macintosh, outrun- dark, black-metal-venom, default-light, heetch, cupcake, material,
-- atelier-sulphurpool-light, mater ia, marrakesh, ia-light, summerfruit-light, heetch-light,
-- atelier-forest-light, atelier-lakeside-light, harmonic-dark, google-dark, mellow-purple,
-- gruvbox-dark-pale, black-metal-immortal, dracula, goo gle-light, gruvbox-dark-medium, embers,
-- twilight, fruit-soda, black-metal-gorgoroth, gruvbox-dark-hard, material-vivid, paraiso,
-- brushtrees-dark, atelier-savanna-light, oceanicnext, cupertino, atelier-heath-light,
-- papercolor-dark, brushtrees, harmonic-light, rebecca, seti, black-metal-bathory, bright, monokai

-- local base16 = require 'base16'
-- base16(base16.themes["gruvbox-dark-hard"], true)

--local theme_names = base16.theme_names()
--base16_position = 1
--function cycle_theme()
--  base16_position = (base16_position % #theme_names) + 1
--  base16(base16.themes[theme_names[base16_position]], true)
--end

-- vim.api.nvim_exec([[
-- " Make background transparent for many things
-- hi! Normal ctermbg=NONE guibg=NONE
-- hi! NonText ctermbg=NONE guibg=NONE
-- hi! LineNr ctermfg=NONE guibg=NONE
-- hi! SignColumn ctermfg=NONE guibg=NONE
-- hi! StatusLine guifg=NONE guibg=NONE
-- hi! StatusLineNC guifg=NONE guibg=NONE
-- " Try to hide vertical split and end of buffer symbol
-- hi! VertSplit gui=NONE guifg=NONE guibg=NONE cterm=NONE
-- hi! EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
-- hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
-- ]], true)
