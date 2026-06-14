if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetMarkdownIndent()
setlocal indentkeys=!^F,o,O,0&,<Space>

function! s:ts_is_active() abort
  return luaeval('require("utils.ts").is_active()')
endfunction

function! s:in_codeblock() abort
  return s:ts_is_active()
        \ ? luaeval('require("utils.ts").find_node("fence") ~= nil')
        \ : luaeval('require("utils.syn").find_group("CodeBlock") ~= nil')
endfunction

" Find the first previous non-blank line that matches the given pattern if
" trimmed, stops on the first line that has a larger indent than its next
" non-blank line
" Returns the line number, the index of the match, and the substring that
" matches the pattern
function! s:prevnonblank_match(lnum, pattern) abort
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

" Check if the given string represents an item in an unordered list
" Returns 0/1
function! s:is_unordered_list(str) abort
  return a:str =~# '^\s*[-*+]\s\+'
endfunction

" Check if the given string represents an item in an ordered list
" Returns the number of the ordered list item if the string represents one,
" 0 otherwise
function! s:is_ordered_list(str) abort
  return str2nr(matchstr(a:str, '\(^\s*\)\@<=\d\+\(\.\ \)\@='))
endfunction

" Check if the given string represents an item in an ordered/unordered list
" Returns a positive integer if true, 0 otherwise
function! s:is_list(str) abort
  return s:is_ordered_list(a:str) || s:is_unordered_list(a:str)
endfunction

function! GetMarkdownIndent() abort
  let l:line = getline(v:lnum)
  let l:indent = indent(v:lnum)
  let l:prevnonblank_lnum = prevnonblank(v:lnum - 1)
  let l:prevnonblank_line = getline(l:prevnonblank_lnum)
  let l:prevnonblank_indent = indent(l:prevnonblank_lnum)

  if l:prevnonblank_lnum == 0
      return l:indent
  endif

  " Treesitter indent in insert mode is laggy, but we need it to get correct
  " indent in code blocks
  " If the code block does not have a language, we should not use
  " nvim-treesitter's indent expr because it always return 0 (no indentation)
  if s:in_codeblock()
    let l:ts_indent = l:indent
    " nvim-treesitter's new default branch 'main' does not have
    " `nvim_treesitter#indent()`
    try
      l:ts_indent = nvim_treesitter#indent()
    catch /^Vim:E117: Unknown function: nvim_treesitter#indent/
      l:ts_indent = luaeval(printf("require('nvim-treesitter.indent').get_indent(%d)", v:lnum))
    endtry
    return l:ts_indent
  endif

  " Current line is not a list item and prev line is non-empty, check if
  " prev line is a list item and align to it accordingly
  if l:prevnonblank_lnum == v:lnum - 1 && ! s:is_list(l:line)
    " Indent unordered list bullet points
    if s:is_unordered_list(l:prevnonblank_line)
      return l:prevnonblank_indent + 2
    endif

    " Indent ordered list items
    let l:order = s:is_ordered_list(l:prevnonblank_line)
    if l:order > 0
      let [l:prevnonblank_heading_lnum, l:_, l:_] = s:prevnonblank_match(v:lnum, '^#')
      let [l:prevnonblank_item_lnum, l:_, l:prevnonblank_item_order] =
            \ s:prevnonblank_match(v:lnum, '^\d\+\.\@=')
      if ! s:in_codeblock() && l:prevnonblank_heading_lnum < l:prevnonblank_item_lnum
        return str2nr(l:order) > l:prevnonblank_item_order
              \ ? indent(l:prevnonblank_item_lnum)
              \ : indent(l:prevnonblank_item_lnum) + (float2nr(log10(l:order)) + 1) + 2
      endif
    endif
  endif

  " If previous line is empty, should use normal indent instead of aligning
  " with the first line of the list item
  " ---------------------------------------------
  " 1234. aaa-bbb
  "       ccc <- should align with the 'aaa'
  " ---------------------------------------------
  " 5678. ddd
  "
  "     eee <- should not align with 'ddd'
  " ---------------------------------------------
  if trim(getline(v:lnum - 1)) ==# ""
    " Find the first prev list item line reversely to decide the indent
    " of current line
    let l:curr_lnum = l:prevnonblank_lnum

    while l:curr_lnum > 0
      let l:curr_line = getline(l:curr_lnum)
      if trim(l:curr_line) ==# "" || s:is_list(l:curr_line)
        break
      endif
      let l:curr_lnum -= 1
    endwhile

    if s:is_list(l:curr_line) && l:indent > indent(l:curr_lnum)
      return indent(l:curr_lnum) + shiftwidth()
    endif
  endif

  return l:indent
endfunction
