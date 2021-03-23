" -< Gruvbox >-
"colorscheme gruvbox

"-> Miramare <-
let g:miramare_enable_italic = 1
let g:miramare_disable_italic_comment = 1
let g:miramare_transparent_background = 1
colorscheme miramare
let g:clap_theme = 'miramare'

lua <<EOF
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
EOF

lua require'colorizer'.setup()
