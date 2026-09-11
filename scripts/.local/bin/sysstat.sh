#!/bin/bash
# Métricas terminal-style para EWW (estilo btop)
BAR_W=12

bar() {
  local p=$1 f e i out=''
  ((p < 0)) && p=0
  ((p > 100)) && p=100
  f=$(((p * BAR_W + 50) / 100))
  e=$((BAR_W - f))
  for ((i = 0; i < f; i++)); do out+='█'; done
  for ((i = 0; i < e; i++)); do out+='░'; done
  printf '%s' "$out"
}

case "$1" in
cpu)
  p=$(top -bn1 | grep -i 'cpu(s)' | awk '{print int($2)}')
  printf 'cpu %s %3d%%' "$(bar "$p")" "$p"
  ;;
ram)
  p=$(free | awk '/^Mem/ {print int($3*100/$2)}')
  printf 'ram %s %3d%%' "$(bar "$p")" "$p"
  ;;
disk)
  p=$(df -h / | awk 'NR==2 {print int($5)}')
  printf 'dsk %s %3d%%' "$(bar "$p")" "$p"
  ;;
temp)
  t=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1)
  [ -z "$t" ] && t=0
  t=$((t / 1000))
  printf 'tmp %s %4s' "$(bar "$t")" "${t}°C"
  ;;
*)
  printf ''
  ;;
esac
