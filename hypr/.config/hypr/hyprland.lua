-- INIT: hyprland.lua
require("conf.programs")
require("conf.keybinds")
require("conf.monitors")
require("conf.input")
require("conf.animations")
require("conf.layout.dwindle")
require("conf.rules")

-- Pasamos una tabla a la función hl.config
hl.config({
  -- 1. Forzar las variables XDG para que el sistema sepa que estás en Hyprland
  env = {
    "XDG_CURRENT_DESKTOP,Hyprland",
    "XDG_SESSION_TYPE,wayland",
    "XDG_SESSION_DESKTOP,Hyprland"
  },

  -- 2. Inyectar estas variables al entorno de DBus (crítico para compartir pantalla)
  exec_once = {
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  },

  -- 3. (Opcional) Si instalaste xwaylandvideobridge para apps antiguas de X11,
  -- estas reglas ocultan su ventana para que no moleste.
  windowrulev2 = {
    "opacity 0.0 override, class:^(xwaylandvideobridge)$",
    "noanim, class:^(xwaylandvideobridge)$",
    "noinitialfocus, class:^(xwaylandvideobridge)$",
    "maxsize 1 1, class:^(xwaylandvideobridge)$",
    "noblur, class:^(xwaylandvideobridge)$"
  }
})
