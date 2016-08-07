{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) stdenv fetchFromGitHub writeText runCommand;

  vim-vader = fetchFromGitHub {
    owner = "junegunn";
    repo = "vader.vim";
    rev = "ad2c752435baba9e7544d0046f0277c3573439bd";
    sha256 = "0yvnah4lxk5w5qidc3y5nvl6lpi8rcv26907b3w7vjskqc935b8f";
  };

  vim-nix = ./.;

  rcFile = writeText "vimrc" ''
    filetype off
    set rtp+=${vim-vader}
    set rtp+=${vim-nix}
    filetype plugin indent on
    syntax enable
  '';

  vim = "${pkgs.vim}/bin/vim";

  env = stdenv.mkDerivation {
    name = "build-environment";
    shellHook = ''
      alias vim='${vim} -XNu ${rcFile} -i NONE'
    '';
  };

in stdenv.mkDerivation {
  name = "vim-nix-2016-08-07";

  src = ./.;

  installPhase = ''
    mkdir -p $out
    cp -r ftdetect ftplugin indent syntax $out
  '';

  checkPhase = ''
    ( ${vim} -XNu ${rcFile} -i NONE -c 'Vader! test/*.vader' ) |& tee vim-nix-test.log >&2
  '';

  doCheck = true;
} // { inherit env; }
