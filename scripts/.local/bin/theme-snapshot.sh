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

aether --generate "$WP" >/dev/null
mkdir -p "$DEST/backgrounds"
cp -n "$WP" "$DEST/backgrounds/" 2>/dev/null || true
rm -rf "$DEST/render"
cp -r "$HOME/.config/aether/theme" "$DEST/render"
echo "snapshot: $NAME"
