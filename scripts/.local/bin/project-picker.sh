#!/usr/bin/env bash
# project-picker.sh — selector de proyectos con fzf, preview de git log +
# lenguaje detectado. Loop persistente: nunca cierra la ventana solo,
# unicamente al presionar ESC en este nivel.
if [ "${MENU_FLOAT:-0}" != 1 ]; then
  export MENU_FLOAT=1
  if command -v ghostty >/dev/null 2>&1; then
    exec ghostty --title=projectpicker -e "$0" "$@"
  elif command -v kitty >/dev/null 2>&1; then
    exec kitty -T projectpicker -e "$0" "$@"
  elif command -v foot >/dev/null 2>&1; then
    exec foot -T projectpicker -e "$0" "$@"
  fi
fi

set -uo pipefail

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/GitHub-Repo}"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

detect_lang() {
  local d="$1"
  if [ -f "$d/justfile" ] || [ -f "$d/Justfile" ]; then
    echo "  just"
  elif [ -f "$d/CMakeLists.txt" ]; then
    echo "  cmake"
  elif [ -f "$d/Cargo.toml" ]; then
    echo "  rust"
  elif [ -f "$d/pom.xml" ]; then
    echo "  maven"
  elif [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ]; then
    echo "  gradle"
  elif [ -f "$d/Makefile" ] || [ -f "$d/makefile" ]; then
    echo " make"
  elif [ -f "$d/go.mod" ]; then
    echo "  go"
  elif [ -f "$d/pyproject.toml" ] || [ -f "$d/requirements.txt" ] || [ -f "$d/setup.py" ]; then
    echo "  python"
  elif ls "$d"/*.ino >/dev/null 2>&1; then
    echo "  arduino"
  elif ls "$d"/*.kt >/dev/null 2>&1; then
    echo "  kotlin"
  elif ls "$d"/*.lua >/dev/null 2>&1; then
    echo "  lua"
  elif ls "$d"/*.sh >/dev/null 2>&1; then
    echo " sh"
  else
    echo "  ?"
  fi
}

list_projects() {
  find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | while read -r d; do
    name=$(basename "$d")
    lang=$(detect_lang "$d")
    printf '%s\t%s  %s\n' "$name" "$lang" "$name"
  done
}

while true; do
  clear
  SEL=$(
    {
      list_projects
      printf '__NEW__\t  Nuevo proyecto\n'
    } | fzf --height=100% --layout=reverse --border \
      --delimiter='\t' --with-nth=2 \
      --prompt='Proyecto  ' \
      --preview="[ {1} = __NEW__ ] && echo 'Crear un proyecto nuevo' || bash '$SELF_DIR/project-preview.sh' '$PROJECTS_DIR/{1}'" \
      --preview-window=right:60%:wrap \
      --header='ENTER: elegir · ESC: salir'
  )

  [ -z "$SEL" ] && break

  NAME=$(echo "$SEL" | cut -f1)

  if [ "$NAME" = "__NEW__" ]; then
    bash "$SELF_DIR/project-new.sh"
  else
    bash "$SELF_DIR/project-menu.sh" "$PROJECTS_DIR/$NAME"
  fi
done
