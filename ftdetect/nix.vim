" Vim filetype detect
" Language:    Nix
" Maintainer:  Daiderd Jordan <daiderd@gmail.com>
" URL:         https://github.com/LnL7/vim-nix

au BufRead,BufNewFile *.nix set filetype=nix
au FileType nix setl sw=2 sts=2 et iskeyword+=-
