#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash jq nix

header="syn keyword nixNamespacedBuiltin contained"

nix __dump-language | jq -r '
  def to_vim: keys | map("  \\ " + . + "\n") | .[];
  [ (.builtins | to_vim)
  , (.constants | del(.["true","false","null","builtins"]) | to_vim)
  ] | add
' | sed -n -i -e '/^'"$header"'/ {
  p; n; r /dev/stdin
  :l; n; /^$/!bl; b
}; p' syntax/nix.vim
