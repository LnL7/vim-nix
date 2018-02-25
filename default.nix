{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) stdenv fetchFromGitHub writeText runCommand;

  vim-vader = fetchFromGitHub {
    owner = "junegunn";
    repo = "vader.vim";
    rev = "ddb714246535e814ddd7c62b86ca07ffbec8a0af";
    sha256 = "0jlxbp883y84nal5p55fxg7a3wqh3zny9dhsvfjajrzvazmiz44n";
  };

  vim-nix = ./.;

  rcFile = writeText "vimrc" ''
    filetype off
    set rtp+=${vim-vader}
    set rtp+=${vim-nix}
    filetype plugin indent on
    syntax enable

    function! Syntax()
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endfunction

    command! Syntax call Syntax()
  '';

  vim = "${pkgs.vim}/bin/vim";

  env = stdenv.mkDerivation {
    name = "build-environment";
    shellHook = ''
      alias vim='${vim} -XNu ${rcFile} -i NONE'
    '';
  };

in stdenv.mkDerivation {
  name = "vim-nix-2017-04-30";
  src = ./.;

  passthru = { inherit env; };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ftdetect ftplugin indent syntax $out
  '';

  checkPhase = ''
    ( ${vim} -XNu ${rcFile} -i NONE -c 'Vader! test/*.vader' ) |& tee vim-nix-test.log >&2
  '';

  doCheck = true;
}
