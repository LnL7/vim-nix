{ pkgs ? import <nixpkgs> {} }:

let

  inherit (pkgs) stdenv fetchFromGitHub writeText runCommand vim;

  # Fallback for nix 1.11
  fetchGit = builtins.fetchGit or (x: x);

  vader = fetchFromGitHub {
    owner = "junegunn";
    repo = "vader.vim";
    rev = "ddb714246535e814ddd7c62b86ca07ffbec8a0af";
    sha256 = "0jlxbp883y84nal5p55fxg7a3wqh3zny9dhsvfjajrzvazmiz44n";
  };

in

stdenv.mkDerivation rec {
  name = "vim-nix-${version}${versionSuffix}";
  version = "0.1.0";
  versionSuffix = "pre${toString src.revCount or 0}.${src.shortRev or "0000000"}";
  src = fetchGit ./.;

  dontBuild = true;
  preferLocalBuild = true;

  buildInputs = [ vim ];

  installPhase = /* sh */ ''
    mkdir -p $out
    cp -r ftdetect ftplugin indent syntax $out
  '';

  vimrc = writeText "vimrc" /* vim */ ''
    filetype off
    set rtp+=${vader}
    set rtp+=${src}
    filetype plugin indent on
    syntax enable

    function! Syntax()
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endfunction

    command! Syntax call Syntax()

    function! Nix_GetScriptID(fname) abort
      let l:snlist = '''
      redir => l:snlist
      silent! scriptnames
      redir END
      let l:mx = '^\s*\(\d\+\):\s*\(.*\)$'
      for l:line in split(l:snlist, "\n")
        if stridx(substitute(l:line, '\\', '/', 'g'), a:fname) >= 0
          return substitute(l:line, l:mx, '\1', ''')
        endif
      endfor
    endfunction
    function! Nix_GetFunc(fname, funcname) abort
      return function('<SNR>' . Nix_GetScriptID(a:fname) . '_' . a:funcname)
    endfunction
  '';

  checkPhase = /* sh */ ''
    ( vim -XNu ${vimrc} -i NONE -c 'Vader! test/*.vader' ) |& tee vim-nix-test.log >&2
  '';

  doCheck = true;

  shellHook = /* sh */ ''
    vim() {
        command vim -XNu ${vimrc} -i NONE "$@"
    }
  '';
}
