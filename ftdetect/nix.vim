" Vim filetype detect
" Language:    Nix
" Maintainer:  Daiderd Jordan <daiderd@gmail.com>
" URL:         https://github.com/LnL7/vim-nix

au BufRead,BufNewFile *.nix setf nix
au BufRead,BufNewFile flake.lock setf json
