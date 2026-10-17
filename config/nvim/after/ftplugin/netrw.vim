setlocal bufhidden=hide
setlocal buftype=nofile
setlocal nobuflisted
setlocal nolist
setlocal nonumber
setlocal norelativenumber
setlocal nospell
setlocal signcolumn=no
setlocal winbar=
let b:undo_ftplugin = empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | '
let b:undo_ftplugin .= 'setlocal bufhidden< buftype< buflisted< list< number< relativenumber< spell< signcolumn< winbar<'
