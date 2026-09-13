#!/bin/bash
# Hyprpaper post-apply: regenerar config apuntando al wallpaper del tema activo

THEME_DIR="$HOME/.config/aether/theme"
BACKGROUND=$(find "$THEME_DIR/backgrounds" -maxdepth 1 -type f | head -n1)

if [ -z "$BACKGROUND" ]; then
  echo "No background found in theme"
  exit 1
fi

MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

cat >"$HOME/.config/hypr/hyprpaper.conf" <<CONF
preload = $BACKGROUND
wallpaper {
    monitor = $MONITOR
    path = $BACKGROUND
    fit_mode = cover
}

splash = false
CONF

systemctl --user restart hyprpaper.service
