-- =====================================================================
-- AUTOSTART - Servicios y Scratchpads al iniciar Hyprland
-- =====================================================================

-- hyprpolkitagent NO va aquí: se gestiona vía systemd --user
-- (systemctl --user enable --now hyprpolkitagent.service)
local services = {
	"nm-applet",
	"eww --force-wayland daemon",
	"~/.local/bin/theme-watch-daemon.sh",
}

hl.on("hyprland.start", function()
	-- Servicios de sistema
	for _, service in ipairs(services) do
		hl.dispatch(hl.dsp.exec_cmd(service))
	end
end)

hl.on("hyprland.shutdown", function()
	-- Lógica de limpieza, guardado de estado o kill de procesos persistentes
end)
