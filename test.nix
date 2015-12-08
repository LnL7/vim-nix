with import <nixpkgs> {};

let
  vader = fetchFromGitHub {
    owner = "junegunn";
    repo = "vader.vim";
    rev = "ad2c752435baba9e7544d0046f0277c3573439bd";
    sha256 = "0yvnah4lxk5w5qidc3y5nvl6lpi8rcv26907b3w7vjskqc935b8f";
  };

  src = ./.;

  rcFile = writeText "vimrc" ''
    filetype off
    set rtp+=${vader}
    set rtp+=${src}
    filetype plugin indent on
    syntax enable
  '';

  run = ''
    ${vim}/bin/vim -XNu '${rcFile}' -i NONE \
      -c 'Vader! ${src}/test/*.vader' > /dev/null
  '';

in runCommand "vim-nix-test.log" {} ''
  (${run}) 2>&1 | tee "$out" >&2
''
