function! nix#find_drv_position()
  let line = search("description")
  if line == 0
    let line = search("name")
  endif
  if line == 0
    echo "error: could not find derivation"
    return
  endif

  return expand("%") . ":" . line
endfunction

function! nix#edit(attr)
  let output = system("nix-instantiate --eval ./. -A " . a:attr . ".meta.position")
  if match(output, "^error:") == -1
    let position = split(split(output, '"')[0], ":")
    execute "edit " . position[0]
    execute position[1]
    " Update default command to nix-build.
    let b:dispatch = 'nix-build --no-out-link -A ' . a:attr
  endif
endfunction

" Takes a list of lines of the form 'key=val'.
function! nix#set_env(lines)
  for l in a:lines
    let [ key; val ] = split(l, "=", 1)
    call setenv(key, join(val, "="))
  endfor
endfunction

" See command :NixShell
function! nix#add_pkg_to_env(args)
  echo "nix-shell " . a:args
  let l:env = systemlist("nix-shell --run env " . a:args)
  call nix#set_env(l:env)
  echo "Environment updated"
endfunction

command! -bang -nargs=* NixEdit call nix#edit(<q-args>)

" Call 'nix-shell' with the given arguments and update the environment as if
" we were inside the spawned shell.
command! -nargs=* NixShell call nix#add_pkg_to_env(<q-args>)
