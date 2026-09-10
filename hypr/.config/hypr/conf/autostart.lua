-- =====================================================================
-- AUTOSTART - Servicios y Scratchpads al iniciar Hyprland
-- =====================================================================
local progs = require("conf.programs")

-- hyprpolkitagent NO va aquí: se gestiona vía systemd --user
-- (systemctl --user enable --now hyprpolkitagent.service)
local services = {
  "waybar",
  "hyprpaper",
  "hypridle",
  "nm-applet",
}

hl.on("hyprland.start", function()
  -- Servicios de sistema
  for _, service in ipairs(services) do
    hl.dispatch(hl.dsp.exec_cmd(service))
  end

  -- Lanzar scratchpads en segundo plano
  -- (las window rules en conf/rules.lua deben estar cargadas ANTES
  -- de este punto para que caigan en su special workspace correcto)
  hl.dispatch(hl.dsp.exec_cmd(progs.monitor))
  hl.dispatch(hl.dsp.exec_cmd(progs.music))
  hl.dispatch(hl.dsp.exec_cmd(progs.notes))
end)

hl.on("hyprland.shutdown", function()
  -- Lógica de limpieza, guardado de estado o kill de procesos persistentes
end)
