-- =====================================================================
-- WINDOW RULES - Reglas de Ventana
-- =====================================================================

-- ==========================================
-- 1. Nautilus - Gestor de Archivos
-- ==========================================
hl.window_rule({
	name = "nautilus_float",
	match = { class = "org.gnome.Nautilus" },
	float = true,
	size = "800 600",
})

-- ==========================================
-- 2. Diálogos de Archivos (Portal XDG)
-- ==========================================
hl.window_rule({
	name = "xdg_portal_float",
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
	pin = true,
	size = "700 500",
})

-- ==========================================
-- 3. SCRATCHPADS (Special Workspaces)
-- ==========================================

-- A. Terminal de Monitoreo (btop en Ghostty)
hl.window_rule({
	name = "scratchpad_monitor",
	match = { class = "com.mitchellh.ghostty", initial_title = "Monitor" },
	workspace = "special:monitor",
	float = true,
	pin = true,
	center = true,
	size = "825 550",
})

-- B. Reproductor de Música (Spotify)
hl.window_rule({
	name = "scratchpad_music",
	match = { class = "spotify" },
	workspace = "special:music",
	float = true,
	pin = true,
	center = true,
})

-- C. Bloc de Notas (Obsidian)
hl.window_rule({
	name = "scratchpad_notes",
	match = { class = "obsidian" },
	workspace = "special:notes",
	float = true,
	pin = true,
	center = true,
})

-- ==========================================
-- 4. EWW - Ventanas de Widgets
-- ==========================================
hl.window_rule({
	name = "eww_float",
	match = { class = "eww" },
	float = true,
	pin = true,
})
