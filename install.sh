#!/bin/bash
set -euo pipefail
echo "[*] Iniciando despliegue"

#Resolucion de dependencias
echo "[*] Instalando dependencias base..."
sudo pacman -Syu --noconfirm

echo "[*] Instalando paquetes de repositorios oficiales..."
if [ -f "pkglist-official.txt" ]; then
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

# Despliegue del pacman hook (no usa Stow: /etc no es $HOME)
echo "[*] Instalando pacman hook de dotfiles..."
if [ -f "pacman/hooks/dotfiles.hook" ]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo cp "pacman/hooks/dotfiles.hook" /etc/pacman.d/hooks/dotfiles.hook
else
  echo "[*] Advertencia: pacman/hooks/dotfiles.hook no encontrado. Saltando"
fi

#despliegue de symlinks (GNU Stow)
echo "[*] Ejectuando motor de enlances simbolicos..."
DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

for dir in */; do
  pkg="${dir%/}"
  echo "-> Procesando paquete: $pkg"
  stow --restow --target="$HOME" "$pkg"
done

# Registro automatico de servicios nuevos (paquetes + custom)
echo "[*] Auto-registrando servicios de usuario..."
if [ -f "scripts/.local/bin/register-services.sh" ]; then
  bash scripts/.local/bin/register-services.sh
fi

# Activacion de servicios de usuario (systemd --user)
echo "[*] Registrando y activando servicios de usuario..."
if [ -f "services-user.txt" ]; then
  while IFS= read -r service || [ -n "$service" ]; do
    [[ -z "$service" || "$service" =~ ^# ]] && continue

    if systemctl --user list-unit-files "$service" &>/dev/null &&
      systemctl --user list-unit-files "$service" | grep -q "$service"; then
      echo "  -> Activando: $service"
      systemctl --user enable --now "$service"
    else
      echo "  -> Advertencia: '$service' no encontrado, saltando (¿paquete instalado?)"
    fi
  done <"services-user.txt"
else
  echo "[*] Advertencia: services-user.txt no encontrado. Saltando"
fi

echo "[*] despliegue completado exitosamente."
