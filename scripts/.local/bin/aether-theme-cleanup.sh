#!/bin/bash
# aether-theme-cleanup.sh — borrado sincronizado wallpaper -> tema
THEMES="$HOME/.config/aether/themes"
USER_WP="$HOME/dotfiles/hypr/.config/hypr/wallpapers_user"

watch_themes() {
    inotifywait -m -r -e delete --format '%w' "$THEMES" 2>/dev/null |
    while read -r dir; do
        case "$dir" in
            */backgrounds/)
                t=$(basename "$(dirname "${dir%/})")
                [ -n "$t" ] && rm -rf "$THEMES/$t"
                ;;
        esac
    done
}

watch_user() {
    inotifywait -m -e delete --format '%f' "$USER_WP" 2>/dev/null |
    while read -r f; do
        [ -n "$f" ] && rm -rf "$THEMES/${f%.*}"
    done
}

watch_themes &
watch_user &
wait
