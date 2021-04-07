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
map þ :Clap filer<CR>
" AltGr l
map ł :Clap blines<CR>
" AltGr .
map · :Clap command<CR>
map <leader>f :Clap files<CR>
map <leader>fg :Clap gfiles<CR>
map <leader>g :Clap grep2<CR>
map <leader>h :Clap history<CR>
map <leader>b :Clap buffers<CR>
map <leader>y :Clap yanks<CR>

" Python Docstring
autocmd FileType python nnoremap <buffer> <leader>pd :Pydocstring<CR>
" commans tabs
nnoremap tn :tabnew<CR>
nnoremap to :tabonly<CR>
nnoremap td :tabclose<CR>
nnoremap tm :tabmove<CR>
" Map BuftabLine
map <silent> <Leader><PageDown> :tabnext<cr>
map <silent> <Leader><PageUp> :tabprevious<cr>
map <silent> <c-]> :BufNext<cr>
map <silent> <c-[> :BufPrev<cr>
map <silent> <a-c> :bd<CR>
map <silent> <leader>t :ToggleBuftabline<cr>
"map <silent> <Leader><PageDown> :tabnext<cr>
"map <silent> <Leader><PageUp> :tabprevious<cr>
"nnoremap <leader>1 1gt
"nnoremap <leader>2 2gt
"nnoremap <leader>3 3gt
"nnoremap <leader>4 4gt
"nnoremap <leader>5 5gt
"map <silent> <Leader><PageDown> :BufferLineCycleNext<CR>
"map <silent> <Leader><PageUP> :BufferLineCyclePrev<CR>
"map <silent> <c-p> :BufferLinePick<CR>
"nnoremap <leader>1 :lua require"bufferline".go_to_buffer(1)<CR>
"nnoremap <leader>2 :lua require"bufferline".go_to_buffer(2)<CR>
"nnoremap <leader>3 :lua require"bufferline".go_to_buffer(3)<CR>
"nnoremap <leader>4 :lua require"bufferline".go_to_buffer(4)<CR>
"nnoremap <leader>5 :lua require"bufferline".go_to_buffer(5)<CR>
" code runner
nmap <silent> <leader>R :belowright 8split term://crlvc %<CR>
"nmap  <silent> <leader>R :Lspsaga open_floaterm crlvc %<CR>

"Terminal open
"nmap <silent> <leader>t :split<CR>:ter<CR>:resize 8<CR>
"Resize pane
nnoremap <silent> <leader><Right> :vertical resize +5<CR>
nnoremap <silent> <leader><Left> :vertical resize -5<CR>
nnoremap <silent> <leader><Up> :resize +5<CR>
nnoremap <silent> <leader><Down> :resize -5<CR>

" Esc in terminal mode
tnoremap <Esc> <C-\><C-n>
tnoremap <M-[> <Esc>
tnoremap <C-v><Esc> <Esc>
" Move line to up or down
nnoremap <A-Down> :m .+1<CR>==
nnoremap <A-Up> :m .-2<CR>==
inoremap <A-Down> <Esc>:m .+1<CR>==gi
inoremap <A-Up> <Esc>:m .-2<CR>==gi
vnoremap <A-Down> :m '>+1<CR>gv=gv
vnoremap <A-Up> :m '<-2<CR>gv=gv
" Delete search result
noremap <silent> <leader>v :let @/=""<cr>
" Esc in insert mode
inoremap jk <Esc>
nnoremap gX :silent :execute
            \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<cr>
"nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
" noremap <Space> zf
" noremap <space> za
nmap <silent><leader>c V :'<,'>lua require('nvim-commaround').toggle_comment()<CR>

"devicons fix bug
if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif
