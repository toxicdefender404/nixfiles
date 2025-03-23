#!/usr/bin/env bash

tracked_changes=$(git diff --name-only)
untracked_files=$(git ls-files --others --exclude-standard)

if [ -z "$tracked_changes" ] && [ -z "$untracked_files" ]; then
  echo "No changes detected, exiting."
  exit 0
fi

git add ./nix/
git diff -U0 --shortstat


alejandra . &>/dev/null || { alejandra . ; echo "formatting failed!" && exit 1; }

nix_changes=$(echo "$tracked_changes" | grep '^nix/')
nix_untracked=$(echo "$untracked_files" | grep '^nix/')

if [ -n "$nix_changes" ] || [ -n "$nix_untracked" ]; then
  echo "Rebuilding..."
  
  sudo nixos-rebuild switch --flake ./nix &>nixos-switch.log || \
    { cat nixos-switch.log | grep --color error && exit 1; }
else
  echo "skipping rebuild"
fi

current=$(nixos-rebuild list-generations | grep current)
git commit -am "$current"