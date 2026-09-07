#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

cd "$DOTFILES_DIR" || exit 1

if git diff --quiet && git diff --cached --quiet; then
  echo "No hay cambios para sincronizar. Saliendo."
  exit 0
fi

git add -A
git commit -m "chore: auto-sync $(date +'%Y-%m-%d %H:%M')"
git push origin master
echo "Sincronizacion completada."
