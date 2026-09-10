-- =====================================================================
-- IDLE & LOCK - Gestión de inactividad y bloqueo de sesión
-- =====================================================================

hl.config({
  hypridle = {
    listener = {
      -- Atenuar brillo antes de bloquear (2.5 min)
      { timeout = 150, on_timeout = "brightnessctl -s set 10",   on_resume = "brightnessctl -r" },

      -- Bloquear sesión (3 min de inactividad)
      { timeout = 180, on_timeout = "hyprlock" },

      -- Apagar pantalla (5 min)
      { timeout = 300, on_timeout = "hyprctl dispatch dpms off", on_resume = "hyprctl dispatch dpms on" },

      -- Suspender sistema (10 min)
      { timeout = 600, on_timeout = "systemctl suspend" },
    },
  },
})
