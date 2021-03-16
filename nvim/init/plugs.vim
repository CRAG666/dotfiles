call plug#begin('~/.config/nvim/plugged')
" Lenguajes
Plug 'elixir-editors/vim-elixir'
"UI
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'p00f/nvim-ts-rainbow'
Plug 'norcalli/nvim-colorizer.lua'
" Text edition
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'AndrewRadev/tagalong.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'KabbAmine/vCoolor.vim'
Plug 'AndrewRadev/splitjoin.vim'
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'aca/completion-tabnine', { 'do': './install.sh' }
Plug 'steelsojka/completion-buffers'
Plug 'nvim-treesitter/completion-treesitter'
" Utils
Plug 'tpope/vim-fugitive'
Plug 'godlygeek/tabular'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'christoomey/vim-tmux-navigator'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'junegunn/fzf.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'szw/vim-maximizer'
" Themes
Plug 'rktjmp/lush.nvim'
Plug 'npxbr/gruvbox.nvim'
Plug 'franbach/miramare'
call plug#end()
