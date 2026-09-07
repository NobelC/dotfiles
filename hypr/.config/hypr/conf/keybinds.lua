-- =====================================================================
-- KEYBINDS - Configuración de Atajos de Teclado
-- =====================================================================
local progs = require("conf.programs")

-- ==========================================
-- 1. Aplicaciones y Sistema
-- ==========================================
hl.bind(progs.mainMod .. " + RETURN", hl.dsp.exec_cmd(progs.terminal))
hl.bind(progs.mainMod .. " + F", hl.dsp.exec_cmd(progs.fileManager))
hl.bind(progs.mainMod .. " + SPACE", hl.dsp.exec_cmd(progs.menu))
hl.bind(progs.mainMod .. " + B", hl.dsp.exec_cmd(progs.browser))
hl.bind(progs.mainMod .. " + BACKSPACE", hl.dsp.window.close())

-- Apagar sistema (con fallback)
hl.bind(progs.mainMod .. " + SHIFT + BACKSPACE",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))

-- ==========================================
-- 2. Gestión de Ventanas
-- ==========================================
hl.bind(progs.mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Toggle Monitor Modes (Mirror / Extend)
hl.bind(progs.mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.local/bin/monitor_mode.sh"))

-- ==========================================
-- 3. Navegación y Foco
-- ==========================================
hl.bind(progs.mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(progs.mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(progs.mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(progs.mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- ==========================================
-- 4. Mover Ventanas en el Workspace
-- ==========================================
hl.bind(progs.mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(progs.mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(progs.mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(progs.mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- ==========================================
-- 5. Espacios de Trabajo (Workspaces)
-- ==========================================
for i = 1, 5 do
  -- Cambiar a workspace
  hl.bind(progs.mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))

  -- Mover ventana activa a workspace (sin seguir)
  hl.bind(progs.mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))

  -- Mover ventana activa a workspace y seguirla
  hl.bind(progs.mainMod .. " + ALT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- ==========================================
-- 6. Teclas Multimedia y Hardware
-- ==========================================
-- Volumen
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })

-- Brillo
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  { locked = true, repeating = true })

-- ==========================================
-- 7. SUBMAPAS - Máquina de Estados de Entrada
-- ==========================================

-- ------------------------------------------
-- SUBMAPA: RESIZE (Redimensionar ventanas)
-- ------------------------------------------
hl.bind(progs.mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  -- Programación defensiva: salir con cualquier tecla no mapeada
  hl.bind("catchall", hl.dsp.submap("reset"))

  -- Salida explícita
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("return", hl.dsp.submap("reset"))

  -- Redimensionar con flechas (repeating para mantener presionado)
  hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
end)

-- ------------------------------------------
-- SUBMAPA: LAYOUT (Manipulación del BSP)
-- ------------------------------------------
hl.bind(progs.mainMod .. " + L", hl.dsp.submap("layout"))

hl.define_submap("layout", function()
  -- Programación defensiva
  hl.bind("catchall", hl.dsp.submap("reset"))

  -- Salida explícita
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("return", hl.dsp.submap("reset"))

  -- Navegación dentro del layout
  hl.bind("left", hl.dsp.focus({ direction = "left" }))
  hl.bind("right", hl.dsp.focus({ direction = "right" }))
  hl.bind("up", hl.dsp.focus({ direction = "up" }))
  hl.bind("down", hl.dsp.focus({ direction = "down" }))

  -- Manipulación del árbol BSP
  hl.bind("s", hl.dsp.layout("togglesplit")) -- Cambiar orientación del split
  hl.bind("w", hl.dsp.layout("swapsplit"))   -- Intercambiar mitades del split
  hl.bind("r", hl.dsp.layout("rotatesplit")) -- Rotar split 90 grados

  -- Pre-seleccionar dirección para la próxima ventana
  hl.bind("h", hl.dsp.layout("preselect left"))
  hl.bind("l", hl.dsp.layout("preselect right"))
  hl.bind("k", hl.dsp.layout("preselect up"))
  hl.bind("j", hl.dsp.layout("preselect down"))

  -- Ajustar split ratio manualmente
  hl.bind("equal", hl.dsp.layout("splitratio +0.1"))  -- Aumentar ratio
  hl.bind("minus", hl.dsp.layout("splitratio -0.1"))  -- Disminuir ratio
  hl.bind("0", hl.dsp.layout("splitratio 1.0 exact")) -- Resetear a 50/50
end)

-- FIN DE KEYBINDS
-- ==========================================
