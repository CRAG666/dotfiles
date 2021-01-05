" -< Turn on syntax highlighting  >-
let python_highlight_all=1
syntax on

" For plug-ins to load correctly.
filetype plugin indent on

let g:ale_disable_lsp = 1

" Remap leader key
let mapleader = " "

" -< Pluggins ﮣ >-
source <sfile>:h/init/plugs.vim

" -< Set compatibility to Vim only. >-
set nocompatible
set noswapfile
set nobackup
set nowritebackup
set nowb
set hidden

"set re=0

" -> Better Colors <-
"set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" Activate mouse
set mouse=a

" Smart ident
set smartindent

" Uncomment below to set the max textwidth. Use a value corresponding to the width of your screen.

set textwidth=88
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround
autocmd Filetype python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab

" Turn off modelines
set modelines=0

" Automatically wrap text that extends beyond the screen length.
set wrap

" Split Config
set splitbelow
set splitright

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Fixes common backspace problems
set backspace=indent,eol,start
" Speed up scrolling in Vim
set ttyfast
" Status bar
set laststatus=2
" Display options
set showmode
set showcmd

" Change directory for currend dir for file
"set autochdir

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Show line numbers
set number relativenumber
"set signcolumn=number

" Set status line display
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch

" Enable incremental search
set incsearch

" Include matching uppercase words with lowercase search term
set ignorecase

" Include only uppercase words with uppercase search term
set smartcase

" Store info from no more than 100 files at a time, 9999 lines of text, 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100
set noshowmode

" Enable folding
"set foldmethod=indent
"set foldlevel=99

"Enable clipboard
set clipboard=unnamedplus

" Files to ignore
source <sfile>:h/init/ignore.vim

" -< Themes Config >-
source <sfile>:h/init/themes.vim

" Ale config
let g:ale_set_highlights = 0

" Rainbow
source <sfile>:h/init/rainbow.vim

" lightline
source <sfile>:h/init/lightline.vim

" Vim
let g:indentLine_color_term = 7
let g:coc_node_path = '/usr/local/bin/node'
let g:gitgutter_sign_added = '✚'
let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_removed = '✖'
let g:gitgutter_sign_removed_first_line = '✖'
let g:gitgutter_sign_modified_removed = '✖'

let g:pydocstring_formatter = 'google'
" NERDTree Config
"source <sfile>:h/init/Nerdtree.vim

" -< Maps   >-
source <sfile>:h/init/maps.vim

" Automatically save and load folds
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview

" Clean end spaces
autocmd BufEnter * :let @/=""
autocmd BufWritePre * %s/\s\+$//e
autocmd CursorHold * silent call CocActionAsync('highlight')
autocmd BufEnter * silent! lcd %:p:h
command! -nargs=0 Prettier :CocCommand prettier.formatFile
