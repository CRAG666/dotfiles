" -< Gruvbox >-
"colorscheme gruvbox

"-> Miramare <-
let g:miramare_enable_italic = 1
let g:miramare_disable_italic_comment = 1
let g:miramare_transparent_background = 1
colorscheme miramare

let g:clap_theme = 'miramare'

lua << EOF
local treesitter = require'nvim-treesitter.configs'
treesitter.setup {
    ensure_installed = "maintained",
    highlight = {
      enable = true
  },
    rainbow = {
      enable = true
  }
}

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
-- base16(base16.themes["ia-dark"], true)

--local theme_names = base16.theme_names()
--base16_position = 1
--function cycle_theme()
--  base16_position = (base16_position % #theme_names) + 1
--  base16(base16.themes[theme_names[base16_position]], true)
--end

require'colorizer'.setup()
EOF

" hi Normal guibg=NONE ctermbg=NONE
" hi Terminal guibg=NONE ctermbg=NONE
" hi EndOfBuffer guibg=NONE ctermbg=NONE
" hi FoldColumn guibg=NONE ctermbg=NONE
" hi Folded guibg=NONE ctermbg=NONE
" hi SignColumn guibg=NONE ctermbg=NONE
" hi LineNr guibg=NONE ctermbg=NONE
" hi CursorLineNR guibg=NONE
