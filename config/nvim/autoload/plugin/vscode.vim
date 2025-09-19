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
function! s:split(...) abort
  let direction = a:1
  let file = exists('a:2') ? a:2 : ''
  call VSCodeCall(direction ==# 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
  if !empty(file)
    call VSCodeExtensionNotify('open-file', expand(file), 'all')
  endif
endfunction

function! s:splitNew(...)
  let file = a:2
  call s:split(a:1, empty(file) ? '__vscode_new__' : file)
endfunction

function! s:closeOtherEditors()
  call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
  call VSCodeNotify('workbench.action.closeOtherEditors')
endfunction

function! s:manageEditorHeight(...)
  let count = a:1
  let to = a:2
  for i in range(1, count ? count : 1)
    call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewHeight' : 'workbench.action.decreaseViewHeight')
  endfor
endfunction

function! s:manageEditorWidth(...)
  let count = a:1
  let to = a:2
  for i in range(1, count ? count : 1)
    call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewWidth' : 'workbench.action.decreaseViewWidth')
  endfor
endfunction

function! plugin#vscode#setup() abort
  " Use VSCode syntax highlighting
  syntax off

  nnoremap K     <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
  nnoremap gD    <Cmd>call <SID>editorAction('goToTypeDefinition')<CR>
  nnoremap gd    <Cmd>call <SID>editorAction('revealDefinition')<CR>
  nnoremap g/    <Cmd>call <SID>editorAction('goToReferences')<CR>
  nnoremap g.    <Cmd>call <SID>editorAction('goToImplementation')<CR>
  nnoremap gq;   <Cmd>call <SID>editorAction('formatDocument')<CR>
  nnoremap <C-]> <Cmd>call <SID>editorAction('revealDefinition')<CR>
  nnoremap gO    <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>

  xnoremap K     <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
  xnoremap gD    <Cmd>call <SID>editorAction('goToTypeDefinition')<CR>
  xnoremap gd    <Cmd>call <SID>editorAction('revealDefinition')<CR>
  xnoremap g/    <Cmd>call <SID>editorAction('goToReferences')<CR>
  xnoremap g.    <Cmd>call <SID>editorAction('goToImplementation')<CR>
  xnoremap gq    <Cmd>call <SID>editorAction('formatSelection')<CR>
  xnoremap <C-]> <Cmd>call <SID>editorAction('revealDefinition')<CR>
  xnoremap gO    <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>

  " Git keymap settings
  nnoremap ]c <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
  nnoremap [c <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>

  " Find files
  nnoremap <Leader>ff <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
  nnoremap <Leader>.  <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>

  " Grep
  nnoremap <Leader>f/ <Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>
  nnoremap <Leader>/  <Cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>

  command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
  command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
  command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
  command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
  command! -bang Only if <q-bang> ==# '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif

  AlterCommand sp[lit] Split
  AlterCommand vs[plit] Vsplit
  AlterCommand new New
  AlterCommand vne[w] Vnew
  AlterCommand on[ly] Only

  " buffer management
  nnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
  nnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

  xnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
  xnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

  " window/splits management
  nnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
  nnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
  nnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
  nnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
  nnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
  nnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
  nnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count, 'increase')<CR>
  nnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count, 'decrease')<CR>
  nnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

  xnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
  xnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
  xnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
  xnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
  xnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
  xnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
  xnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count, 'increase')<CR>
  xnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count, 'decrease')<CR>
  xnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

  " window navigation
  nnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
  nnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
  nnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
  nnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
  nnoremap <C-w>H <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
  nnoremap <C-w>J <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
  nnoremap <C-w>K <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
  nnoremap <C-w>L <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
  nnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
  nnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
  nnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

  xnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
  xnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
  xnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
  xnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
  xnoremap <C-w>H <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
  xnoremap <C-w>J <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
  xnoremap <C-w>K <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
  xnoremap <C-w>L <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
  xnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
  xnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
  xnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
endfunction
