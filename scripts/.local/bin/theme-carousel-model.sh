#!/bin/bash
# theme-carousel-model.sh — modelo JSON de la biblioteca de temas de Aether
THEMES="$HOME/.config/aether/themes"
THUMBS="$HOME/.cache/wall-thumbs"
mkdir -p "$THUMBS"

first() { local p; for p in "$@"; do [ -e "$p" ] && { echo "$p"; return; }; done; }

out="["
for d in "$THEMES"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    colors="${d}colors.toml"
    [ -f "$colors" ] || continue
    wp=$(first ${d}backgrounds/*)
    [ -n "$wp" ] || continue
    b=$(basename "$wp")
    thumb="$THUMBS/$b"
    [ -f "$thumb" ] || ffmpeg -y -loglevel error -i "$wp" -vf scale=480:270 "$thumb"
    rfield=""
    [ -d "${d}render" ] && rfield=",\"render\":\"${d}render\""
    out+="{\"name\":\"$name\",\"colors\":\"$colors\",\"wallpaper\":\"$wp\",\"thumb\":\"$thumb\"$rfield},"
done
echo "${out%,}]"
