#!/usr/bin/env bash
# brimenu.sh — menú de brillo con presets y valor custom
if [ "${MENU_FLOAT:-0}" != 1 ]; then export MENU_FLOAT=1;
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=brimenu -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T brimenu -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T brimenu -e "$0" "$@"
  fi
fi

set -uo pipefail

CUR=$(brightnessctl get 2>/dev/null)
MAX=$(brightnessctl max 2>/dev/null)
[ -z "$MAX" ] || [ "$MAX" -eq 0 ] && {
  notify-send "Brillo" "Sin backlight controlable" -u critical
  exit 1
}
PCT=$((CUR * 100 / MAX))

SEL=$(
  printf '%s\n' 5 10 20 30 40 50 60 70 80 90 100 |
    fzf --print-query --height=40% --layout=reverse --border \
      --prompt='Brillo %  ' --header="actual: ${PCT}% · o escribe un número" |
    tail -1
)

[[ "$SEL" =~ ^[0-9]+$ ]] && brightnessctl set "$((SEL > 100 ? 100 : SEL))%"
