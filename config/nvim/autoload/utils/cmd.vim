" Split string using shell-like syntax
" Wrapper of Python3 `shlex.split()`, see: https://stackoverflow.com/a/44946430
"
" param: str string
" param: notify boolean? notify when python3 provider or the `shlex` package
"        is unavailable, default `true`
" return: string[]
function! utils#cmd#split(str, ...) abort
  let notify = get(a:, 1, v:false)

  " Python3 provider is lazy-loaded, see `lua/core/opts.lua`, so first try
  " loading python3 provider to get python3 support
  if !has('python3')
    unlet g:loaded_python3_provider
    runtime! provider/python3.vim
  endif

  " If python3 is still unavailable, return empty result
  if !has('python3')
    if notify
      echoerr printf("[utils#cmd] cannot split command string '%s': python3 provider unavailable", str)
    endif
    return {}
  endif

  python3 import shlex
  python3 import vim
  return py3eval("shlex.split(vim.eval('a:str'))")
endfunction
