" Leader for multi cursors
"let g:VM_leader =
let g:VM_maps = {}
let g:VM_maps["Select All"] = 'æ'
"Fuzzy finder configuration to use the ripgrep tool
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.5,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }
let g:fzf_tags_command = 'ctags -R'
"let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
let $FZF_DEFAULT_COMMAND = 'rg --files'
" Clap map
let g:clap_open_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
let g:clap_provider_grep_opts = '--hidden -g "!.git/" "!__pycache__/"'
" AltGr p
map þ :Clap files<CR>
map <leader>g :Rg<CR>
map <leader>f :Clap filer<CR>
" AltGr l
map ł :Clap blines<CR>
map <leader>b :Clap buffers<CR>
map · :Clap command<CR>
map <leader>gf :Clap gfiles<CR>
map <leader>h :Clap history<CR>
map <leader>y :Clap yanks<CR>

"Refactor rename
nmap <leader>rn <Plug>(coc-rename)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Python Docstring
autocmd FileType python nnoremap <buffer> <leader>pd :Pydocstring<CR>
"search
nnoremap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>
" commans tabs
nnoremap tn :tabnew<CR>
nnoremap to :tabonly<CR>
nnoremap td :tabclose<CR>
nnoremap tm :tabmove<CR>
map <silent> <Leader><PageDown> :tabnext<cr>
map <silent> <Leader><PageUp> :tabprevious<cr>
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
" code runner
"nmap <silent> <leader>R :belowright 8split term://crlvc %<CR>
nmap  <silent> <leader>R :FloatermNew --height=0.6 --width=0.8 --wintype=floating --name=Code_Runner  --autoclose=0 crlvc %<CR>
"Terminal open
nmap <silent> <leader>t :split<CR>:ter<CR>:resize 8<CR>
nmap <silent> <leader>tf :FloatermNew<CR>

nnoremap <silent> <leader><Right> :vertical resize +5<CR>
nnoremap <silent> <leader><Left> :vertical resize -5<CR>
nnoremap <silent> <leader><Up> :resize +5<CR>
nnoremap <silent> <leader><Down> :resize -5<CR>

" Esc in terminal mode
tnoremap <Esc> <C-\><C-n>
tnoremap <M-[> <Esc>
tnoremap <C-v><Esc> <Esc>
" Navigate in the ale wrap
nmap <A-Left> <Plug>(ale_previous_wrap)
nmap <A-Right> <Plug>(ale_next_wrap)
" Move line to up or down
nnoremap <A-Down> :m .+1<CR>==
nnoremap <A-Up> :m .-2<CR>==
inoremap <A-Down> <Esc>:m .+1<CR>==gi
inoremap <A-Up> <Esc>:m .-2<CR>==gi
vnoremap <A-Down> :m '>+1<CR>gv=gv
vnoremap <A-Up> :m '<-2<CR>gv=gv
" Delete search result
noremap <silent> <leader>c :let @/=""<cr>
" Esc in insert mode
inoremap jk <Esc>
" Vim's auto indentation feature does not work properly with text copied from outisde of Vim. Press the <F2> key to toggle paste mode on/off.
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F2>

" prettier
vmap <A-f>  <Plug>(coc-format-selected)
nmap <A-f>  <Plug>(coc-format-selected)

"Markdown Preview
nmap <leader>mp <Plug>MarkdownPreview
nmap <leader>ms <Plug>MarkdownPreviewStop
nmap <leader>mt <Plug>MarkdownPreviewToggle
nnoremap gX :silent :execute
            \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<cr>
"nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
"vnoremap <Space> zf
"nnoremap <space> za

" devicons fix bug
"if exists("g:loaded_webdevicons")
  "call webdevicons#refresh()
"endif

