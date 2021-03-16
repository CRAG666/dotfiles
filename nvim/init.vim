" -< Turn on syntax highlighting  >-
let python_highlight_all=1
syntax on

" For plug-ins to load correctly.
filetype plugin indent on

" Remap leader key
let mapleader = " "

" -< Pluggins ﮣ >-
source <sfile>:h/init/plugs.vim

" -< No swap and cache >-
set noswapfile
set nobackup
set nowritebackup
set nowb
set hidden

" -> Better Colors <-
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

" Speed up scrolling in Vim
set ttyfast
" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Status bar
set laststatus=2
" Display options
set showmode
set showcmd

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Fixes common backspace problems
set backspace=indent,eol,start

" Show line numbers
set number relativenumber
"set signcolumn=number

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
set foldmethod=indent
set foldlevel=99
"Foldin for especially filetype
"autocmd FileType vim setlocal foldmethod=marker

" Enable clipboard
set clipboard=unnamedplus

" Config grep command
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set grepformat=%f:%l:%c:%m

" gitgutter icons
let g:gitgutter_sign_added = '✚'
let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_removed = '✖'
let g:gitgutter_sign_removed_first_line = '✖'
let g:gitgutter_sign_modified_removed = '✖'
" Python documentation
let g:pydocstring_formatter = 'google'

" Clean end spaces
autocmd BufEnter * :let @/=""
autocmd BufWritePre * %s/\s\+$//e

" Current path file
autocmd BufEnter * silent! lcd %:p:h

" -< Status line config >-
function! ConfigStatusLine()
  lua require('plugins.statusline')
endfunction

augroup status_line_init
  autocmd!
  autocmd VimEnter * call ConfigStatusLine()
augroup END

source <sfile>:h/init/themes.vim
source <sfile>:h/init/maps.vim
source <sfile>:h/init/func.vim
source <sfile>:h/init/ignore.vim
source <sfile>:h/init/lsp.vim
