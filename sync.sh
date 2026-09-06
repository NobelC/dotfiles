#!/bin/bash
set -euo pipefail

cd "$HOME/dotfiles"

# Abortar si no hay cambios
if [[ -z $(git status --porcelain) ]]; then
    exit 0
fi

git add .
git commit -m "chore: auto-sync $(date +'%Y-%m-%d %H:%M')"
git push origin master
