#!/bin/bash
WALLPAPER=$(find "$HOME/.config/aether/theme/backgrounds" -maxdepth 1 -type f | head -n1)

if [ -z "$WALLPAPER" ]; then
  exit 0
fi

# Sincronizar wallpaper activo hacia wallpapers_user (punto comun,
# versionado en git) si no existe ya ahi.
WALLPAPERS_USER="$HOME/dotfiles/hypr/.config/hypr/wallpapers_user"
FILENAME=$(basename "$WALLPAPER")

mkdir -p "$WALLPAPERS_USER"
if [ ! -f "$WALLPAPERS_USER/$FILENAME" ]; then
  cp "$WALLPAPER" "$WALLPAPERS_USER/$FILENAME"
fi

MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

cat >"$HOME/.config/hypr/hyprpaper.conf" <<EOF
preload = $WALLPAPER

wallpaper {
    monitor = $MONITOR
    path = $WALLPAPER
    fit_mode = cover
}

splash = false
EOF

systemctl --user restart hyprpaper.service
