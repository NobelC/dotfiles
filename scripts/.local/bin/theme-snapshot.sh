#!/bin/bash
# theme-snapshot.sh <wallpaper> — aplica y cachea un render consistente.
# Un render completo solo existe tras un apply real: los templates de
# custom hooks (waybar-style.css.tpl, walker.css, mako.ini...) no se
# renderizan con --no-apply, que solo produce el core.
set -e
WP="$1"
[ -f "$WP" ] || { echo "uso: theme-snapshot.sh <wallpaper>"; exit 1; }
NAME=$(basename "$WP"); NAME="${NAME%.*}"
DEST="$HOME/.config/aether/themes/$NAME"
CANON_DIR="$HOME/dotfiles/hypr/.config/hypr/wallpapers/user"

aether --generate "$WP" >/dev/null
mkdir -p "$DEST/backgrounds"
cp -n "$WP" "$DEST/backgrounds/" 2>/dev/null || true
rm -rf "$DEST/render"
cp -r "$HOME/.config/aether/theme" "$DEST/render"

# Copia el wallpaper a la carpeta canonica local (no versionada), a
# menos que ya venga de ahi o de la carpeta de ejemplos versionada.
case "$WP" in
  "$CANON_DIR"/*|*/wallpapers/arch/*) ;;
  *)
    mkdir -p "$CANON_DIR"
    cp -n "$WP" "$CANON_DIR/" 2>/dev/null || true
    ;;
esac

echo "snapshot: $NAME"
