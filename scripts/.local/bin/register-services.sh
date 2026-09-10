#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
SCOPE_FILE="$DOTFILES_DIR/services-scope.txt"
SERVICES_FILE="$DOTFILES_DIR/services-user.txt"
CUSTOM_UNITS_DIR="$DOTFILES_DIR/systemd/.config/systemd/user"

cd "$DOTFILES_DIR" || exit 1

touch "$SERVICES_FILE"
touch "$SCOPE_FILE"

added=0
activated=0

is_template_unit() {
  # Unidades tipo nombre@.service requieren una instancia, no se activan tal cual
  [[ "$1" == *"@."* ]]
}

activate() {
  local service="$1"

  if is_template_unit "$service"; then
    echo "  -> Omitido (plantilla, requiere instancia): $service"
    return
  fi

  if systemctl --user is-enabled "$service" &>/dev/null; then
    return
  fi

  if systemctl --user list-unit-files "$service" &>/dev/null &&
    systemctl --user list-unit-files "$service" | grep -q "$service"; then
    echo "  -> Activando: $service"
    if systemctl --user enable --now "$service" 2>/dev/null; then
      activated=$((activated + 1))
    else
      echo "     (no se pudo activar, revisa manualmente)"
    fi
  fi
}

register() {
  local service="$1"
  local source="$2"
  if ! grep -qxF "$service" "$SERVICES_FILE"; then
    echo "$service" >>"$SERVICES_FILE"
    echo "  -> Registrado ($source): $service"
    added=$((added + 1))
  fi
  activate "$service"
}

echo "[*] Escaneando servicios de paquetes en la lista blanca (services-scope.txt)..."
while IFS= read -r pkg || [ -n "$pkg" ]; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

  if ! pacman -Qq "$pkg" &>/dev/null; then
    continue
  fi

  while IFS= read -r unit_path; do
    service_name="$(basename "$unit_path")"
    register "$service_name" "paquete:$pkg"
  done < <(pacman -Ql "$pkg" 2>/dev/null | grep -E '/usr/lib/systemd/user/.*\.service$' | awk '{print $2}')
done <"$SCOPE_FILE"

echo "[*] Escaneando demonios propios (systemd/.config/systemd/user)..."
if [ -d "$CUSTOM_UNITS_DIR" ]; then
  while IFS= read -r unit_path; do
    service_name="$(basename "$unit_path")"
    register "$service_name" "custom"
  done < <(find "$CUSTOM_UNITS_DIR" -maxdepth 1 -type f -name "*.service" 2>/dev/null || true)
else
  echo "  -> Advertencia: $CUSTOM_UNITS_DIR no existe aun. Saltando."
fi

if [ "$added" -eq 0 ] && [ "$activated" -eq 0 ]; then
  echo "[*] Nada nuevo que registrar o activar."
else
  echo "[*] $added servicio(s) nuevo(s) registrado(s), $activated activado(s)."
fi
