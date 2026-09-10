#!/bin/bash
# fullwidth.sh - Redimensiona la ventana activa para ocupar todo el workspace respetando gaps

GAPS_OUT=10
BORDER=2

# Obtener resolución del monitor activo
MONITOR=$(hyprctl activewindow -j | jq -r '.monitor')
RES=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | \"\(.width) \(.height)\"")

if [ -z "$RES" ]; then
  # Fallback: usar el primer monitor
  RES=$(hyprctl monitors -j | jq -r '.[0] | "\(.width) \(.height)"')
fi

W=$(echo "$RES" | awk '{print $1}')
H=$(echo "$RES" | awk '{print $2}')

# Calcular tamaño restando gaps y bordes
NEW_W=$((W - 2 * GAPS_OUT - 2 * BORDER))
NEW_H=$((H - 2 * GAPS_OUT - 2 * BORDER))

hyprctl dispatch resizeactive exact $NEW_W $NEW_H
