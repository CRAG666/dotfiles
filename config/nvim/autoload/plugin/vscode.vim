if !exists('g:vscode')
  finish
endif

" LSP keymap settings
function! s:editorAction(str)
  if exists('b:vscode_controlled') && b:vscode_controlled
    call VSCodeNotify('editor.action.' . a:str)
  else
    " Allow to function in help files
    exe "normal! \<C-]>"
  endif
endfunction

" Window and buffer keymap settings
function! plugin#vscode#setup() abort
  " Use VSCode syntax highlighting, disable regex and treesitter highlighting
  " Also disable nvim's LSP client
  syntax off
  lua vim.treesitter.start = function() end
  lua vim.lsp.start = function() end

  " Avoid colorcolumn artifacts
  set colorcolumn=

  " Prevent nvim message from showing up after searching/undo
  " https://stackoverflow.com/questions/78611905/turn-off-neovim-messages-in-vscode
  set cmdheight=10

  " LSP keymaps
  nnoremap gD        <Cmd>call VSCodeNotify('editor.action.goToTypeDefinition')<CR>
  nnoremap g/        <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>
  nnoremap g.        <Cmd>call VSCodeNotify('editor.action.goToImplementation')<CR>
  nnoremap gq;       <Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>
  nnoremap gO        <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
  nnoremap <Leader>s <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>

  " Open file explorer, avoid opening netrw/oil.nvim
  nnoremap - <Cmd>call VSCodeNotify('workbench.view.explorer')<CR>

  " Git keymap settings
  nnoremap ]c <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
  nnoremap [c <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>

  " Fuzzy find/grep
  nnoremap <Leader>ff <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
  nnoremap <Leader>.  <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
  nnoremap <Leader>f/ <Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>
  nnoremap <Leader>/  <Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>
endfunction
