#!/usr/bin/env bash
# project-preview.sh <ruta> — usado como --preview de project-picker.sh
D="$1"
[ -d "$D" ] || exit 0

echo -e "\033[1;36m$(basename "$D")\033[0m"
echo

if [ -d "$D/.git" ]; then
  echo -e "\033[1;33mUltimos commits:\033[0m"
  git -C "$D" log -5 --oneline --color=always 2>/dev/null
  echo
  branch=$(git -C "$D" branch --show-current 2>/dev/null)
  dirty=$(git -C "$D" status --porcelain 2>/dev/null)
  echo -e "\033[1;33mRama:\033[0m $branch$([ -n "$dirty" ] && echo ' (cambios sin commitear)')"
  echo
fi

echo -e "\033[1;33mArbol:\033[0m"
eza --tree --level=2 --icons=auto --group-directories-first "$D" 2>/dev/null | head -20
