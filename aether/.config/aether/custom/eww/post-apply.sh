#!/bin/bash
# Dueño del symlink de variables + señal de reload al daemon persistente
ln -sfn "$HOME/.config/aether/theme/waybar-style.css.tpl" "$HOME/.config/eww/colors-aether.css"
eww reload
