lua << EOF
local lspc = require 'lspconfig'
lspc.pyright.setup{}
lspc.elixirls.setup{}


local saga = require 'lspsaga'
saga.init_lsp_saga()
EOF

let g:completion_chain_complete_list = {
      \ 'default': [
      \    {'complete_items': ['lsp', 'ts', 'snippet', 'tabnine', 'buffers']},
      \    {'mode': '<c-p>'},
      \    {'mode': '<c-n>'}
      \]
      \}

fun! EnableCompletion()
    " Don't Enable Completion on these clap
    if &ft =~ 'clap_input'
        return
    endif
    let g:completion_enable_auto_popup = 1
    lua require'completion'.on_attach()
endfun

autocmd FileType clap_input let g:completion_enable_auto_popup = 0
autocmd BufEnter * call EnableCompletion()


 "Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

 "Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

 "Avoid showing message extra message when using completion
set shortmess+=c

lua require('lspkind').init({})

nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <silent><leader>ca <cmd>'<,'>lua require('lspsaga.codeaction').range_code_action()<CR>
nnoremap <silent> K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
nnoremap <silent> gs <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
nnoremap <silent>gr <cmd>lua require('lspsaga.rename').rename()<CR>
nnoremap <silent> gD <cmd>lua require'lspsaga.provider'.preview_definition()<CR>
nnoremap <silent><leader>cd <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
nnoremap <silent> [e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
nnoremap <silent> ]e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>
nnoremap <silent> <A-d> <cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>
tnoremap <silent> <A-d> <C-\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>
