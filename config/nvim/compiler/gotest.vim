" Vim compiler file
" Compiler:         Go Test
" Maintainer:       Bekaboo <kankefengjing@gmail.com>
" Latest Revision:  Mon Jun  9 20:03:28 2025

if exists("g:current_compiler")
  finish
endif
let g:current_compiler = "gotest"

let s:cpo_save = &cpo
set cpo&vim

if exists('g:gotest_makeprg_params')
  CompilerSet makeprg=go\ test\ '.escape(g:gotest_makeprg_params, ' \|"').'\ $*'
else
  CompilerSet makeprg=go\ test\ $*
endif

CompilerSet errorformat =%-G#%.%#                                              " Ignore lines starting with '#', e.g. # github.com/pkg [github.com/pkg.test]
CompilerSet errorformat+=%E%\\s%#Error\ Trace:%\\s%\\+%f:%l                    " Start of multi-line error: Error Trace: some_test.go:123
CompilerSet errorformat+=%Z%\\s%#Error:%\\s%\\+%m                              " End of multi-line error: Error: ...

CompilerSet errorformat+=%E%.%#:\ test\ panicked:\ %m                          " Start of multi-line panic: test panicked: ...
CompilerSet errorformat+=%C%\\s%\\+%.%#(%.%#0x%\\x%\\+%.%#)                    " Ignore first panic stack trace message, use message following 'test panicked:'
CompilerSet errorformat+=%C%\\s%\\+%.%#()                                      " ...
CompilerSet errorformat+=%Z%\\s%\\+%f:%l\ +0x%\\x%\\+                          " End multi-line panic with the first panic stack trace: /xxx/stack.go:123 +0x64
CompilerSet errorformat+=%+A%\\s%\\+%.%#(%.%#0x%\\x%\\+%.%#)                   " Following stack trace message: github.com/xxx/suite.failOnPanic(0x14000583880, {0x1053ba500, 0x14001570690})
CompilerSet errorformat+=%+A%\\s%\\+%.%#()                                     " ...
CompilerSet errorformat+=%+A%\\s%\\+created\ by\ %.%#\ in\ goroutine\ %\\d%\\+ " Following stack trace message: created by testing.(*T).Run in goroutine 50
CompilerSet errorformat+=%C%.%#                                                " Stack trace continuation

CompilerSet errorformat+=%f:%l:%c:\ %m                                         " Single-line error message: pkg/some_test.go:123:45: ...

let &cpo = s:cpo_save
unlet s:cpo_save
