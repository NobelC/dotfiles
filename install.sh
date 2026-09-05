#!/bin/bash
set -euo pipefail
echo "[*] Iniciando despliegue"

#Resolucion de dependencias
echo "[*] Instalando dependencias base..."
sudo pacman -S --needed --noconfirm stow git neovim curl base-devel

#Topologia de directorios
echo "[*] Preparando esqueleto del sistema de archivos..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share"

#despliegue de symlinks (GNU Stow)
echo "[*] Ejectuando motor de enlances simbolicos..."
DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

for dir in */; do
  pkg="${dir%/}"
  echo "-> Procesando paquete: $pkg"
  stow --restow --target="$HOME" "$pkg"
done

echo "[*] despliegue completado exitosamente."
