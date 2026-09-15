#!/usr/bin/env bash
# netmenu.sh — selector de Wi-Fi: nmcli + fzf
# Sin TTY (click waybar): se re-ejecuta en el terminal disponible
if [ "${MENU_FLOAT:-0}" != 1 ]; then export MENU_FLOAT=1;
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=netmenu -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T netmenu -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T netmenu -e "$0" "$@"
  fi
fi

set -uo pipefail

# Interfaz Wi-Fi real, detectada (portable entre máquinas)
WIFI_IF=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2 == "wifi" {print $1; exit}')
[ -z "$WIFI_IF" ] && {
  notify-send "Red" "Sin adaptador Wi-Fi" -u critical
  exit 1
}

# Radio apagado -> encender antes de listar
if [ "$(nmcli -t -f WIFI g 2>/dev/null)" = "disabled" ]; then
  nmcli radio wifi on
  sleep 1
fi

CURRENT=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '/^yes:/{print $2}')

CHOICE=$(
  nmcli -t -f SSID,SIGNAL,SECURITY dev wifi 2>/dev/null |
    sort -t: -k2 -rn |
    awk -F: '!seen[$1]++ {printf "%s\t%3s%%  %s\n", $1, $2, ($3 == "" ? "abierta" : $3)}' |
    fzf --height=60% --layout=reverse --border \
      --prompt='Red  ' \
      --header='ENTER conectar/desconectar · ESC salir' |
    cut -f1
)

[ -z "$CHOICE" ] && exit 0

# Red actual -> desconectar
if [ "$CHOICE" = "$CURRENT" ]; then
  nmcli device disconnect "$WIFI_IF" &&
    notify-send "Red" "Desconectado de $CHOICE" ||
    notify-send "Red" "Falló al desconectar" -u critical
  exit 0
fi

# Perfil guardado -> conectar sin pedir nada
if nmcli -t -f NAME con show 2>/dev/null | grep -qFx "$CHOICE"; then
  nmcli connection up id "$CHOICE" &&
    notify-send "Red" "Conectado a $CHOICE" ||
    notify-send "Red" "Falló al conectar a $CHOICE" -u critical
  exit 0
fi

# Red nueva: nmcli pide la contraseña en esta misma terminal
nmcli device wifi connect "$CHOICE" &&
  notify-send "Red" "Conectado a $CHOICE" ||
  notify-send "Red" "Falló al conectar a $CHOICE" -u critical
read -rp "Pulsa ENTER para cerrar…" _
