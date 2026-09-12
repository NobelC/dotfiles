#!/bin/bash
# Hook de Aether: symlink en vez de copy para evitar mutar el repo
ln -sfn "$HOME/.config/aether/theme/wofi.css" "$HOME/.config/wofi/colors-aether.css"
