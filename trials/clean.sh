#!/bin/bash
# Removes the trial worktrees and their docsite-trial/* branches from the target repos. Usage: trials/clean.sh REPO...
for repo in "$@"; do
  git -C "$repo" worktree list --porcelain | sed -n 's/^worktree //p' | grep '/docsite-trials/' | while read -r tree; do
    git -C "$repo" worktree remove --force "$tree"
  done
  git -C "$repo" for-each-ref --format='%(refname:short)' 'refs/heads/docsite-trial/*' | xargs -n1 git -C "$repo" branch -D
done
