if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetMarkdownIndent()
setlocal indentkeys=!^F,o,O,0&,<Space>

function! s:in_codeblock(...) abort
  let l:lnum = get(a:000, 0, v:lnum)
  let l:bufnr = get(a:000, 1, bufnr('%'))
  return luaeval(printf('require("utils.ft.markdown").in_codeblock(%d, %d)'
        \ , l:lnum, l:bufnr))
endfunction

function! s:ts_is_active() abort
  return luaeval('require("utils.ts").is_active()')
endfunction

" Find the first previous non-blank line that matches the given pattern if
" trimmed, stops on the first line that has a larger indent than its next
" non-blank line
" Returns the line number, the index of the match, and the substring that
" matches the pattern
function! s:prev_match(lnum, pattern) abort
  let l:lnum = prevnonblank(a:lnum - 1)
  let l:indent = indent(l:lnum)
  while l:lnum >= 1
    let l:line = trim(getline(l:lnum))
    let l:match_idx = match(l:line, a:pattern)
    let l:match = matchstr(l:line, a:pattern)
    if l:match_idx >= 0
      return [l:lnum, l:match_idx, l:match]
    endif
    let l:lnum = prevnonblank(l:lnum - 1)
    let l:new_indent = indent(l:lnum)
    if l:new_indent <= l:indent
      let l:indent = l:new_indent
    else
      break
    endif
  endwhile
  return [0, -1, '']
endfunction

function! GetMarkdownIndent() abort
  let l:line = getline(v:lnum)
  let l:prev_lnum = prevnonblank(v:lnum - 1)
  let l:prev_line = getline(l:prev_lnum)
  let l:sw = shiftwidth()
  let l:default = indent(v:lnum)
  if l:prev_lnum == 0
      return l:default
  endif

  " Treesitter indent in insert mode is laggy, but we need it to get correct
  " indent in code blocks
  " If the code block does not have a language, in which case we should not
  " nvim-treesitter's indent expr because it always return 0 (no indentation)
  let codeblock_lang = s:in_codeblock()
  if s:ts_is_active() &&
        \ codeblock_lang !=# v:false &&
        \ codeblock_lang !=# '' &&
        \ codeblock_lang !~# 'markdown'
    return nvim_treesitter#indent()
  endif

  " Indent unordered list bullet points
  if l:line =~# '^\s*[-*+]\s\+$'
    return l:default / l:sw * l:sw
  endif

  " Indent ordered list items
  let l:order = str2nr(matchstr(l:line, '\(^\s*\)\@<=\d\+\(\.\ \)\@='))
  if l:order > 0
    let [l:prev_heading_lnum, l:_, l:_] = s:prev_match(v:lnum, '^#')
    let [l:prev_item_lnum, l:_, l:prev_item_order] =
          \ s:prev_match(v:lnum, '^\d\+\.\@=')
    if s:in_normalzone(l:prev_item_lnum, 1) &&
          \ l:prev_heading_lnum < l:prev_item_lnum
      return str2nr(l:order) > l:prev_item_order
            \ ? indent(l:prev_item_lnum)
            \ : indent(l:prev_item_lnum) + l:sw
    endif
  endif

  " Only align multi-line list items if adjacent previous line is non-empty
  " ---------------------------------------------
  " 1234. aaa-bbb
  "       ccc <- should align with the 'aaa'
  " ---------------------------------------------
  " 5678. ddd
  "
  "     eee <- should not align with 'ddd'
  " ---------------------------------------------
  if l:line =~# '^\s*$' && l:prev_lnum == v:lnum - 1 &&
        \ s:in_normalzone(l:prev_lnum, 1)
    " Align unordered list multi-line items
    let l:prev_line_char_pos = match(l:prev_line, '\(^\s*[-*+]\s\+\)\@<=\S')
    if l:prev_line_char_pos >= 0
      return l:prev_line_char_pos
    endif
    " Align ordered list multi-line items
    let l:ordered_list_extra_indent =
          \ match(l:prev_line, '\(^\s*\d\+\.\s*\)\@<=\S')
    if l:ordered_list_extra_indent >= 0
      return l:ordered_list_extra_indent
    endif
  endif

  return l:default
endfunction
