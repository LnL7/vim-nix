" Vim filetype detect
" Language:    Nix
" Maintainer:  Daiderd Jordan <daiderd@gmail.com>
" URL:         https://github.com/LnL7/vim-nix

function! s:unbackslash(str)
  return substitute(a:str, '\\\(.\)', '\1', 'g')
endfunction

" Parse a shell command line into a list of words, à la Perl's shellwords or
" Python's shlex.split.
function! s:shellwords(str)
  let l:args = []
  let l:len = len(a:str)
  let l:i = 0
  let l:new = 1 " does a new word need to be created?
  while l:i < l:len
    let [l:match, l:start, l:end] = matchstrpos(a:str, '^\s\+', l:i) " whitespace
    if l:end >= 0
      let l:i = l:end
      let l:new = 1
      continue
    endif
    if l:new " there are more words to come
      call add(l:args, '')
      let l:new = 0
    endif
    let [l:match, l:start, l:end] = matchstrpos(a:str, '^\([^''"\\[:space:]]\|\\.\)\+', l:i) " unquoted text
    if l:end >= 0
      let l:args[-1] ..= s:unbackslash(l:match)
      let l:i = l:end
      continue
    endif
    let [l:match, l:start, l:end] = matchstrpos(a:str, "^'[^']*'", l:i) " single quotes
    if l:end >= 0
      let l:args[-1] ..= l:match[1:-2]
      let l:i = l:end
      continue
    endif
    let [l:match, l:start, l:end] = matchstrpos(a:str, '^"\([^"\\]\|\\.\)*"', l:i) " double quotes
    if l:end >= 0
      let l:args[-1] ..= s:unbackslash(l:match[1:-2])
      let l:i = l:end
      continue
    endif
    throw "shellwords: failed to parse arguments"
  endwhile
  return l:args
endfunction

function! DetectNixShell()
  if getline(1) =~# '^#!.*nix-shell'
    for l:line in getline(2, '$')
      let l:pos = matchend(l:line, '\C^#!\s*nix-shell\s\+')
      if l:pos >= 0
        let l:interpreter = 0
        try
          for l:arg in s:shellwords(l:line[l:pos :])
            if l:arg ==# '-i'
              let l:interpreter = 1
            elseif l:interpreter
              " TODO expose and use vim's interpreter → filetype conversion logic
              let &l:filetype = l:arg
              return
            endif
          endfor
        catch
          return
        endtry
      endif
    endfor
  endif
endfunction

au BufRead,BufNewFile *.nix setf nix
au BufRead,BufNewFile flake.lock setf json
au BufRead,BufNewFile * if !did_filetype() | call DetectNixShell() | endif
