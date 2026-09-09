#!/bin/bash

# 1. Escaneo automático de monitores
# Detecta la pantalla de la laptop (suele empezar con eDP)
LAPTOP=$(hyprctl monitors all -j | jq -r '.[] | select(.name | startswith("eDP")) | .name' | head -n 1)
# Detecta cualquier otra pantalla conectada
EXTERNAL=$(hyprctl monitors all -j | jq -r '.[] | select(.name != "'$LAPTOP'") | .name' | head -n 1)

if [ -z "$EXTERNAL" ]; then
  notify-send "Monitores" "No se detectó ninguna pantalla externa."
  exit 0
fi

STATE_FILE="/tmp/hypr_monitor_state"

if [ ! -f "$STATE_FILE" ] || [ "$(cat $STATE_FILE)" == "mirror" ]; then
  # ==========================================
  # MODO 2: Independencia de Trabajo (Extend)
  # ==========================================
  # Configura el monitor a la derecha de la laptop
  hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
  hyprctl keyword monitor "$LAPTOP,preferred,0x0,1"

  # Ancla workspaces 1-5 a la laptop, y 6-10 al externo
  for i in {1..5}; do hyprctl keyword workspace "$i,monitor:$LAPTOP"; done
  for i in {6..10}; do hyprctl keyword workspace "$i,monitor:$EXTERNAL"; done

  echo "extend" >"$STATE_FILE"
  notify-send "Modo Monitor" "Independiente (5 Workspaces por pantalla)"
else
  # ==========================================
  # MODO 1: Duplicado Total (Mirror)
  # ==========================================
  # Sobrescribe el monitor externo para que sea un espejo de la laptop
  hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$LAPTOP"

  echo "mirror" >"$STATE_FILE"
  notify-send "Modo Monitor" "Duplicado (Mirroring)"
fi
