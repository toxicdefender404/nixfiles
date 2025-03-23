#!/usr/bin/env bash

tracked_changes=$(git diff --name-only)
untracked_files=$(git ls-files --others --exclude-standard)

if [ -z "$tracked_changes" ] && [ -z "$untracked_files" ]; then
  echo "No changes detected, exiting."
  exit 0
fi


alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

echo "Staged changes:"
git diff -U0 --compact-summary

echo "NixOS Rebuilding..."

git add ./nix/

# rebuild and output simplified errors
sudo nixos-rebuild switch --flake ./nix &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)


# Get current generation metadata for commit message
current=$(nixos-rebuild list-generations | grep current)

git commit -am "$current"
