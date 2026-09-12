#!/bin/bash
# theme-watch-daemon.sh — notificación de cambio de tema independiente del cambiador
exec 9>/tmp/theme-watch.lock
flock -n 9 || exit 0

THEME_FILE="$HOME/.config/aether/theme/waybar-style.css.tpl"

inotifywait -m -q -e close_write -e moved_to "$(dirname "$THEME_FILE")" 2>/dev/null |
  while read -r dir ev file; do
    [ "$file" = "$(basename "$THEME_FILE")" ] || continue
    sleep 0.3 # debounce: un apply escribe varios archivos; coalesces el burst
    eww reload
  done
