" Vim indent file
" Language:    Nix
" Maintainer:  Daiderd Jordan <daiderd@gmail.com>
" URL:         https://github.com/LnL7/vim-nix

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent

setlocal indentexpr=GetNixIndent()

if exists("*GetNixIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:skip_syntax  = '\%(Comment\|String\)$'
let s:block_close  = '\%(}\|]\)'
let s:block_skip   = "synIDattr(synID(line('.'),col('.'),1),'name') =~? '" . s:skip_syntax . "'"

function! GetNixIndent()
  let lnum = prevnonblank(v:lnum - 1)
  let ind  = indent(lnum)

  " At the start of the file use zero indent.
  if lnum == 0
    return 0
  endif

  if synIDattr(synID(v:lnum, 1, 1), "name") !~ s:skip_syntax
    let current_line = getline(v:lnum)
    let last_line = getline(lnum)

    let splited_line = split(last_line, '\zs')
    let opened_symbol = 0
    let opened_symbol += count(splited_line, '{') - count(splited_line, '}')
    let opened_symbol += count(splited_line, '[') - count(splited_line, ']')

    let ind += opened_symbol * &sw

    if current_line =~ '^\s*}'
      let bslnum = searchpair('{', '', '}', 'nbW', s:block_skip)
      let ind = indent(bslnum)
    endif

    if current_line =~ '^\s*]'
      let bslnum = searchpair('[', '', ']', 'nbW', s:block_skip)
      let ind = indent(bslnum)
    endif

    if current_line =~ '^\s*)'
      let bslnum = searchpair('(', '', ')', 'nbW', s:block_skip)
      let ind = indent(bslnum)
    endif

    if current_line =~ '^\s*' . s:block_close
      let ind -= &sw
    endif
  endif

  return ind
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
