#!/bin/bash
# wallpaper-picker.sh - Selector de wallpaper con walker que dispara
# la extraccion y aplicacion de colores via Aether.

WALLPAPER_DIR="$HOME/dotfiles/hypr/.config/hypr/wallpapers_user"

selected=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; |
  sort |
  walker --dmenu --placeholder "Elige un wallpaper:")

if [ -z "$selected" ]; then
  exit 0
fi

FULL_PATH="$WALLPAPER_DIR/$selected"

if [ ! -f "$FULL_PATH" ]; then
  notify-send "Wallpaper Picker" "Archivo no encontrado: $selected"
  exit 1
fi

notify-send "Wallpaper Picker" "Aplicando tema desde $selected..."
aether --generate "$FULL_PATH"
