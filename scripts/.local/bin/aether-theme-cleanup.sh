#!/bin/bash
# aether-theme-cleanup.sh — borrado sincronizado wallpaper -> tema(s)
# Un wallpaper puede estar copiado dentro de multiples carpetas de tema
# (ej. snapshots con nombre curado a mano, como "arch-linux-two"), asi
# que al borrar de wallpapers/user/ hay que barrer TODAS las carpetas
# de tema que contengan una copia con el mismo nombre de archivo.
THEMES="$HOME/.config/aether/themes"
USER_WP="$HOME/dotfiles/hypr/.config/hypr/wallpapers/user"
THUMBS="$HOME/.cache/wall-thumbs"

watch_themes() {
    inotifywait -m -r -e delete --format '%w' "$THEMES" 2>/dev/null |
    while read -r dir; do
        case "$dir" in
            */backgrounds/)
                t=$(basename "$(dirname "${dir%/}")")
                [ -n "$t" ] && rm -rf "$THEMES/$t"
                ;;
        esac
    done
}

watch_user() {
    inotifywait -m -e delete --format '%f' "$USER_WP" 2>/dev/null |
    while read -r f; do
        [ -z "$f" ] && continue

        # Barre TODA la libreria de temas buscando carpetas cuyo
        # backgrounds/ contenga un archivo con este mismo nombre,
        # sin importar el nombre de la carpeta de tema en si.
        for bg in "$THEMES"/*/backgrounds/"$f"; do
            [ -e "$bg" ] || continue
            theme_dir="$(dirname "$(dirname "$bg")")"
            rm -rf "$theme_dir"
        done

        rm -f "$THUMBS/$f"
    done
}

watch_themes &
watch_user &
wait
