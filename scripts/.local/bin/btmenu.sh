#!/usr/bin/env bash
# btmenu.sh — menú Bluetooth: bluetoothctl + fzf
# Sin TTY (click waybar): se re-ejecuta en el terminal disponible
if [ "${MENU_FLOAT:-0}" != 1 ]; then export MENU_FLOAT=1;
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=btmenu -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T btmenu -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T btmenu -e "$0" "$@"
  fi
fi

set -uo pipefail

ADAPTER=$(bluetoothctl list 2>/dev/null | head -1 | awk '{print $2}')
[ -z "$ADAPTER" ] && {
  notify-send "Bluetooth" "bluez no ve ningún adaptador" -u critical
  exit 1
}

POWER=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')

SEL=$(
  {
    if [ "$POWER" = "yes" ]; then
      echo "#POWER  apagar adaptador"
    else
      echo "#POWER  encender adaptador"
    fi
    echo "#SCAN   buscar y emparejar dispositivo nuevo"
    bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
      CONN=$(bluetoothctl info "$mac" 2>/dev/null | awk '/Connected: yes/{print "●"; exit}')
      printf '%s  %s  %s\n' "${CONN:-○}" "$name" "$mac"
    done
  } | fzf --height=60% --layout=reverse --border \
    --prompt='BT   ' \
    --header="adaptador: $ADAPTER · powered: $POWER · ENTER acción · ESC salir"
)

[ -z "$SEL" ] && exit 0

case "$SEL" in
"#POWER"*)
  if [ "$POWER" = "yes" ]; then
    bluetoothctl power off && notify-send "Bluetooth" "Adaptador apagado"
  else
    bluetoothctl power on && notify-send "Bluetooth" "Adaptador encendido"
  fi
  ;;
"#SCAN"*)
  bluetoothctl power on
  notify-send "Bluetooth" "Escaneando 15 segundos…"
  bluetoothctl --timeout 15 scan on >/dev/null 2>&1
  PICK=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
    if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
      printf '%s  %s\n' "$name" "$mac"
    fi
  done | fzf --height=50% --border --prompt='Emparejar  ' | awk '{print $NF}')
  if [ -n "$PICK" ]; then
    bluetoothctl pair "$PICK" &&
      bluetoothctl trust "$PICK" &&
      bluetoothctl connect "$PICK" &&
      notify-send "Bluetooth" "Emparejado y conectado" ||
      notify-send "Bluetooth" "Falló el emparejamiento" -u critical
  fi
  ;;
"")
  exit 0
  ;;
*)
  MAC=${SEL##* }
  if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
    bluetoothctl disconnect "$MAC" && notify-send "Bluetooth" "Desconectado de ${SEL%  *}"
  else
    bluetoothctl connect "$MAC" && notify-send "Bluetooth" "Conectado a ${SEL%  *}" ||
      notify-send "Bluetooth" "Falló la conexión" -u critical
  fi
  ;;
esac
