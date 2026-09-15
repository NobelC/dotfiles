#!/usr/bin/env bash
# volmenu.sh — menú de audio: mute, volumen, micrófono, salida por defecto
if [ "${MENU_FLOAT:-0}" != 1 ]; then export MENU_FLOAT=1;
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=volmenu -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T volmenu -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T volmenu -e "$0" "$@"
  fi
fi

set -uo pipefail

read -r VOL_PCT MUTED < <(
  wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
    awk '{printf "%d %s", $2*100, (/MUTED/ ? "[MUTED]" : "")}'
)
read -r MIC_PCT MIC_MUTED < <(
  wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
    awk '{printf "%d %s", $2*100, (/MUTED/ ? "[MUTED]" : "")}'
)

pick_vol() {
  printf '%s\n' 0 5 10 20 30 40 50 60 70 80 90 100 |
    fzf --print-query --height=40% --border --prompt="$1" --header="o escribe un número" |
    tail -1
}

SEL=$(
  {
    echo "#MUTE     salida: ${VOL_PCT}% ${MUTED} (toggle mute)"
    echo "#VOL      ajustar volumen de salida"
    echo "#MICMUTE  entrada: ${MIC_PCT}% ${MIC_MUTED} (toggle mute)"
    echo "#VOLMIC   ajustar volumen de entrada"
    wpctl status 2>/dev/null |
      awk '/Sinks:/{f=1;next} /Sources:|Controls:|Clients:/{f=0} f' |
      grep -E '[0-9]+\.' |
      sed -E 's/^[^0-9]*([0-9]+)\. (.*)$/SINK \1 \2/'
  } | fzf --height=50% --layout=reverse --border \
    --prompt='Audio  ' --header="ENTER acción · ESC salir"
)

case "$SEL" in
"#MUTE"*)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  ;;
"#VOL"*)
  V=$(pick_vol 'Volumen %  ')
  [[ "$V" =~ ^[0-9]+$ ]] && wpctl set-volume @DEFAULT_AUDIO_SINK@ "$((V > 100 ? 100 : V))%"
  ;;
"#MICMUTE"*)
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
  ;;
"#VOLMIC"*)
  V=$(pick_vol 'Micrófono %  ')
  [[ "$V" =~ ^[0-9]+$ ]] && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "$((V > 100 ? 100 : V))%"
  ;;
SINK\ *)
  ID=${SEL#SINK }
  ID=${ID%% *}
  wpctl set-default "$ID" && notify-send "Audio" "Salida cambiada"
  ;;
esac
