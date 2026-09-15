#!/usr/bin/env bash
# project-menu.sh <ruta-proyecto> — menu de acciones en loop.
# ESC vuelve al project-picker (no cierra la ventana).
set -uo pipefail

D="$1"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME=$(basename "$D")

ACTIONS="Build
Test
Run
Lint
Abrir en Neovim
Abrir shell aqui
Git log completo
Arbol completo
Doctor (verificar toolchains)
Eliminar este proyecto"

while true; do
  clear
  SEL=$(echo "$ACTIONS" | fzf --height=60% --layout=reverse --border \
    --prompt="$NAME  " --header='ENTER: ejecutar · ESC: volver')

  [ -z "$SEL" ] && break

  case "$SEL" in
  "Build" | "Test" | "Run" | "Lint")
    clear
    ACTION_LOWER=$(echo "$SEL" | tr '[:upper:]' '[:lower:]')
    bash "$SELF_DIR/project-run.sh" "$ACTION_LOWER" "$D"
    echo
    read -rp "Presiona ENTER para volver al menu..." _
    ;;
  "Abrir en Neovim")
    (cd "$D" && nvim .)
    ;;
  "Abrir shell aqui")
    echo "Escribe 'exit' para volver al menu."
    (cd "$D" && exec "$SHELL")
    ;;
  "Git log completo")
    git -C "$D" log --oneline --graph --decorate -30 | less -R
    ;;
  "Arbol completo")
    eza --tree --icons=auto --group-directories-first --git-ignore "$D" | less -R
    ;;
  "Doctor (verificar toolchains)")
    clear
    bash "$SELF_DIR/project-doctor.sh"
    echo
    read -rp "Presiona ENTER para volver al menu..." _
    ;;
  "Eliminar este proyecto")
    clear
    echo "Vas a eliminar PERMANENTEMENTE: $D"
    read -rp "Escribe el nombre del proyecto para confirmar ($NAME): " CONFIRM
    if [ "$CONFIRM" = "$NAME" ]; then
      rm -rf "$D"
      notify-send "Project Picker" "Eliminado: $NAME"
      break
    else
      echo "Cancelado (no coincide el nombre)."
      sleep 1
    fi
    ;;
  esac
done
