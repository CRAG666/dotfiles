call plug#begin('~/.config/nvim/plugged')
" Lenguajes
Plug 'elixir-editors/vim-elixir'
"UI
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'frazrepo/vim-rainbow'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'norcalli/nvim-colorizer.lua'
" Text edition
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'AndrewRadev/tagalong.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'KabbAmine/vCoolor.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Utils
Plug 'tpope/vim-fugitive'
Plug 'godlygeek/tabular'
Plug 'dense-analysis/ale'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'christoomey/vim-tmux-navigator'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'voldikss/vim-floaterm'
Plug 'junegunn/fzf.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
" Themes
Plug 'ghifarit53/tokyonight-vim'
Plug 'sainnhe/sonokai'
Plug 'co1ncidence/monokai-pro.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'franbach/miramare'
call plug#end()
