#!/usr/bin/env bash
# powmenu.sh — menú de energía: estado, perfiles, límite de carga, suspensión
if [ "${MENU_FLOAT:-0}" != 1 ]; then export MENU_FLOAT=1;
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=powmenu -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T powmenu -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T powmenu -e "$0" "$@"
  fi
fi

set -uo pipefail

BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -m1 '^BAT')
[ -z "$BAT" ] && {
  notify-send "Energía" "Sin batería detectada" -u critical
  exit 1
}

CAP=$(cat "/sys/class/power_supply/$BAT/capacity")
STATUS=$(cat "/sys/class/power_supply/$BAT/status")
POWER_W=$(awk -v p="$(cat "/sys/class/power_supply/$BAT/power_now" 2>/dev/null || echo 0)" \
  'BEGIN{printf "%.1f", p/1000000}')

PROFILE=""
command -v powerprofilesctl >/dev/null 2>&1 && PROFILE=$(powerprofilesctl get 2>/dev/null)

THRESH="/sys/class/power_supply/$BAT/charge_control_end_threshold"
LIMIT=""
[ -w "$THRESH" ] && LIMIT=$(cat "$THRESH")

HEADER="$CAP% · $STATUS · ${POWER_W}W"
[ -n "$PROFILE" ] && HEADER="$HEADER · perfil: $PROFILE"

SEL=$(
  {
    if [ -n "$PROFILE" ]; then
      echo "#PROFILE  cambiar perfil de energía"
    fi
    if [ -n "$LIMIT" ]; then
      echo "#LIMIT    límite de carga (hoy: $LIMIT%)"
    fi
    echo "#SUSPEND  suspender el equipo"
  } | fzf --height=40% --layout=reverse --border \
    --prompt='Energía  ' --header="$HEADER · ENTER acción · ESC salir"
)

case "$SEL" in
"#PROFILE"*)
  PICK=$(powerprofilesctl list 2>/dev/null | grep ':$' | tr -d ':' |
    fzf --height=40% --border --prompt='Perfil  ')
  [ -n "$PICK" ] && powerprofilesctl set "$PICK" &&
    notify-send "Energía" "Perfil: $PICK"
  ;;
"#LIMIT"*)
  if [ "$LIMIT" -lt 100 ]; then
    echo 100 >"$THRESH" && notify-send "Energía" "Límite de carga: 100%"
  else
    echo 80 >"$THRESH" && notify-send "Energía" "Límite de carga: 80% (cuida la batería)"
  fi
  ;;
"#SUSPEND"*)
  systemctl suspend
  ;;
esac
