-- =====================================================================
-- AESTHETICS - Configuración visual de Hyprland
-- =====================================================================

hl.config({
  general = {
    -- Bordes y Esquinas
    border_size = 2,

    -- Gaps Globales
    gaps_in = 5,
    gaps_out = 5,
    gaps_workspaces = 0,

    -- Colores de bordes (activo/inactivo)
    col = {
      active_border = "rgba(7aa2f7ff)",
      inactive_border = "rgba(414868ff)",
      nogroup_border = "rgba(313244ff)",
      nogroup_border_active = "rgba(7aa2f7ff)",
    },
  },
})

hl.config({
  decoration = {
    -- Blur (Desenfoque)
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      popups = true,
      popups_ignorealpha = 0.2,
    },

    -- Sombras
    shadow = {
      enabled = true,
      range = 8,
      render_power = 3,
      color = "rgba(00000066)",
      color_inactive = "rgba(00000033)",
      offset = "0 2",
    },

    -- Opacidad
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    fullscreen_opacity = 1.0,
    dim_inactive = false,
  },
})

hl.config({
  animations = {
    enabled = true,
  },
})

hl.config({
  cursor = {
    inactive_timeout = 0,
    hide_on_key_press = true,
  },
})
