" Make vim-dispatch pick shipped pytest compiler plugin for `python3 -m pytest`
" command, see
" - `:h dispatch-:Dispatch`
" - `$VIMRUNTIME/compiler/pytest.vim`

" Pytest can be run with different commands, see
" https://github.com/vim-test/vim-test/blob/8c76f6c0953edaa13a37c29ac9c6a7bb56ddce89/autoload/test/python/pytest.vim#L54-L64
"
" Set `makeprg` based on different conditions so that vim-dispatch can detect
" them and use this compiler for `errorformat`
if     filereadable('Pipfile')     | CompilerSet makeprg=pipenv\ run\ pytest
elseif filereadable('poetry.lock') | CompilerSet makeprg=poetry\ run\ pytest
elseif filereadable('pdm.lock')    | CompilerSet makeprg=pdm\ run\ pytest
elseif filereadable('uv.lock')     | CompilerSet makeprg=uv\ run\ pytest
else                               | CompilerSet makeprg=python3\ -m\ pytest
endif

" Remove '%+G...' formats to avoid including general messages without
" corresponding file locations in quickfix
for efm in split(&efm, ',')
  if efm =~# '%+G'
    exe 'CompilerSet errorformat-=' . escape(efm, '\\ ')
  endif
endfor

" Ignore lines with timestamps in json, e.g. 2025-06-14 22:29:59 which can be
" confused with the `filename:line:column` pattern
CompilerSet errorformat^=%-G%.%#%\\d%\\{4}-%\\d%\\{2}-%\\d%\\{2}\ %\\d%\\{2}:%\\d%\\{2}%.%#

" Traceback: File "xxx.py", line 123, in some_func
CompilerSet errorformat+=%\\s%\\+File\ \"%f\"\\,\ line\ %l\\,\ %m
