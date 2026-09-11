#!/bin/bash
# Verifica el estado de muteo de la fuente de audio por defecto (Micrófono)
MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c "MUTED")

if [ "$MUTE" -eq 1 ]; then
  echo "󰍭" # Ícono de micrófono muteado
else
  echo "󰍬" # Ícono de micrófono activo
fi
