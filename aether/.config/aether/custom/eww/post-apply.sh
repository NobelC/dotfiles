echo "[$(date +%T)] eww hook ejecutado, ppid=$PPID" >> /tmp/aether-hooks.log
#!/bin/bash
# Dueño del symlink de variables + señal de reload al daemon persistente
ln -sfn "$HOME/.config/aether/theme/waybar-style.css.tpl" "$HOME/.config/eww/colors-aether.css"
eww reload
