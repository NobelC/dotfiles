#!/usr/bin/env bash

set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOT_DIR"

timestamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

case "${1:-}" in
    full)
        file="$SCREENSHOT_DIR/$(timestamp).png"

        grim "$file"
        wl-copy < "$file"
        ;;

    region)
        file="$SCREENSHOT_DIR/$(timestamp).png"

        geometry="$(slurp)"

        [[ -n "$geometry" ]] || exit 0

        grim -g "$geometry" "$file"
        wl-copy < "$file"
        ;;

    window)
        file="$SCREENSHOT_DIR/$(timestamp).png"

        geometry="$(hyprctl activewindow -j | jq -r \
            '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"

        grim -g "$geometry" "$file"
        wl-copy < "$file"
        ;;

    *)
        echo "Usage: $0 {full|region|window}"
        exit 1
        ;;
esac
