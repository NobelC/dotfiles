#!/bin/bash
set -euo pipefail
echo "[*] Iniciando despliegue"

#Resolucion de dependencias
echo "[*] Instalando dependencias base..."
sudo pacman -Syu --noconfirm

echo "[*] Instalando paquetes de repositorios oficiales..."
if [ -f "pkglist-oficial.txt" ]; then
  sudo pacman -S --needed --noconfirm - <pkglist-official.txt
else
  echo "[*] Advertencia : pkglist-official.txt no encontrado. Saltando"
fi

if command -v yay &>/dev/null; then
  echo "[*] Instalando paquetes del AUR.."
  if [ -f "pkglist-aur.txt" ]; then
    yay -S --needed --noconfirm - <pkglist-aur.txt
  fi
else
  echo "[*] 'yay' no esta instalado."
fi

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
