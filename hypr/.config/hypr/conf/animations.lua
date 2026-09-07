-- =====================================================================
-- ANIMATIONS & CURVES (Minimalista, Duro y Sutil)
-- =====================================================================

hl.config({
  animations = {
    enabled = true,
  }
})

-- ==========================================
-- 1. Curvas (Física)
-- ==========================================
hl.curve("rigid", { type = "bezier", points = { { 0.15, 1 }, { 0.2, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- ==========================================
-- 2. Árbol de Animaciones (Animation Tree)
-- ==========================================
hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "rigid" })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "rigid", style = "popin 95%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "rigid", style = "popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "linear", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "rigid" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })

hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "rigid", style = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "linear" })
