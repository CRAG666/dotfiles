"-> sonokai (default, atlantis, andromeda, shusia, maia) <-
"let g:sonokai_style = 'shusia'
"let g:sonokai_enable_italic = 1
"let g:sonokai_disable_italic_comment = 1
"let g:sonokai_transparent_background = 1
"let g:sonokai_diagnostic_line_highlight = 0
"let g:sonokai_better_performance = 1
"colorscheme sonokai

"-< Monokai >-
"colorscheme monokai-pro

"-< Gruvbox
"let g:gruvbox_material_transparent_background = 1
"let g:gruvbox_material_palette = 'mix' " available: mix, material, original
"let g:gruvbox_material_background = 'hard' " available: soft, medium, hard
"let g:gruvbox_material_enable_italic = 1
"let g:gruvbox_material_disable_italic_comment = 1
"colorscheme gruvbox-material

"-> Miramare <-
let g:miramare_enable_italic = 1
let g:miramare_disable_italic_comment = 1
let g:miramare_transparent_background = 1
colorscheme miramare
let g:clap_theme = 'miramare'

" -< Tokyonight >-
"let g:tokyonight_style = 'night' " available: night, storm
"let g:tokyonight_enable_italic = 1
"let g:tokyonight_disable_italic_comment = 1
"let g:tokyonight_transparent_background = 1
"colorscheme tokyonight

lua <<EOF
local treesitter = require'nvim-treesitter.configs'
treesitter.setup {
    ensure_installed = "maintained",
    highlight = {
  enable = true
  }
}
EOF

lua require'colorizer'.setup()
