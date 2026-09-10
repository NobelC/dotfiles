#!/bin/bash
# expand_horizontal.sh - Toggle: expande la ventana activa a todo el ancho
# del monitor (respetando gaps/bordes) sin tocar el alto. Si ya esta
# expandida, restaura su tamaño y posicion anteriores.

set -euo pipefail

GAPS_OUT=10
BORDER=2

STATE_DIR="/tmp/hypr_expand_state"
mkdir -p "$STATE_DIR"

WIN_JSON=$(hyprctl activewindow -j)
ADDR=$(echo "$WIN_JSON" | jq -r '.address')

if [ -z "$ADDR" ] || [ "$ADDR" == "null" ]; then
  notify-send "Expand Horizontal" "No hay ventana activa."
  exit 0
fi

STATE_FILE="$STATE_DIR/${ADDR//0x/}"

if [ -f "$STATE_FILE" ]; then
  # ==========================================
  # RESTAURAR: ya estaba expandida
  # ==========================================
  read -r PREV_W PREV_H PREV_X PREV_Y <"$STATE_FILE"

  hyprctl dispatch resizeactive exact "$PREV_W" "$PREV_H"
  hyprctl dispatch moveactive exact "$PREV_X" "$PREV_Y"

  rm -f "$STATE_FILE"
else
  # ==========================================
  # EXPANDIR: guardar estado actual y expandir
  # ==========================================
  CUR_W=$(echo "$WIN_JSON" | jq -r '.size[0]')
  CUR_H=$(echo "$WIN_JSON" | jq -r '.size[1]')
  CUR_X=$(echo "$WIN_JSON" | jq -r '.at[0]')
  CUR_Y=$(echo "$WIN_JSON" | jq -r '.at[1]')

  echo "$CUR_W $CUR_H $CUR_X $CUR_Y" >"$STATE_FILE"

  MONITOR=$(echo "$WIN_JSON" | jq -r '.monitor')
  RES=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | \"\(.width) \(.height)\"")

  if [ -z "$RES" ]; then
    RES=$(hyprctl monitors -j | jq -r '.[0] | "\(.width) \(.height)"')
  fi

  W=$(echo "$RES" | awk '{print $1}')
  NEW_W=$((W - 2 * GAPS_OUT - 2 * BORDER))

  hyprctl dispatch resizeactive exact "$NEW_W" 0
fi
