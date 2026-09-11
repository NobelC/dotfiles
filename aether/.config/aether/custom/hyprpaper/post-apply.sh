#!/bin/bash
WALLPAPER=$(find "$HOME/.config/aether/theme/backgrounds" -maxdepth 1 -type f | head -n1)

if [ -z "$WALLPAPER" ]; then
  exit 0
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
