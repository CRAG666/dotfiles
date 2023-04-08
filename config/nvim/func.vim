" Search an Replace in all files
fu! sar(v1, v2)
  let pattern=a:v1
  let replacement=a:v2
  execute "grep " .pattern
  execute "cfdo %s/" .pattern. "/" .replacement. "/ge | update"
endfunction

command! -nargs=+ Sraf call Sraf(split(<q-args>, ' ')[0], split(<q-args>, ' ')[1])

