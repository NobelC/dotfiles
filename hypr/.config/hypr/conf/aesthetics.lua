-- =====================================================================
-- AESTHETICS - Configuración visual de Hyprland
-- =====================================================================

local ok, theme = pcall(require, "theme_colors")
if not ok then
	-- Fallback tokyonight, por si Aether aun no genero el tema
	theme = {
		active_border = "rgba(7aa2f7ff)",
		inactive_border = "rgba(414868ff)",
		background = "rgba(1a1b26ff)",
	}
end

hl.config({
	-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
	general = {
		-- Bordes y Esquinas
		border_size = 2,

		-- Gaps Globales
		gaps_in = 5,
		gaps_out = 5,
		gaps_workspaces = 0,

		-- Colores de bordes (activo/inactivo) - dinamicos via Aether
		col = {
			active_border = theme.active_border,
			inactive_border = theme.inactive_border,
			nogroup_border = "rgba(313244ff)",
			nogroup_border_active = theme.active_border,
		},
	},

	-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
	decoration = {
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			new_optimizations = true,
			ignore_opacity = true,
			popups = true,
			popups_ignorealpha = 0.2,
		},

		shadow = {
			enabled = true,
			range = 8,
			render_power = 3,
			color = "rgba(00000066)",
			color_inactive = "rgba(00000033)",
			offset = "0 2",
		},

		active_opacity = 1.0,
		inactive_opacity = 0.95,
		fullscreen_opacity = 1.0,
		dim_inactive = false,
	},

	cursor = {
		inactive_timeout = 0,
		hide_on_key_press = true,
	},
})
