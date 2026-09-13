#!/bin/bash
# theme-snapshot.sh — cachea el tema activo en la biblioteca renderizada
WP=$(find ~/.config/aether/theme/backgrounds -maxdepth 1 -type f | head -1)
[ -n "$WP" ] || exit 1
NAME=$(basename "$WP")
NAME="${NAME%.*}"
DEST="$HOME/.config/aether/themes/$NAME"
mkdir -p "$DEST/backgrounds"
cp -n "$WP" "$DEST/backgrounds/" 2>/dev/null
rm -rf "$DEST/render"
cp -r ~/.config/aether/theme "$DEST/render"
echo "snapshot: $NAME"
