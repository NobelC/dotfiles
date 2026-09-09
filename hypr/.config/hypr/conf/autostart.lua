local services = {
  "waybar",
  "hyprpaper",
  "nm-applet",
}

local progs = require("conf.programs")

hl.on("hyprland.start", function()
  for _, service in ipairs(services) do
    hl.dispatch(hl.dsp.exec_cmd(service))
  end
end)

hl.on("hyprland.start", function()
  -- Servicios existentes
  for _, service in ipairs({ "waybar", "hyprpaper", "nm-applet" }) do
    hl.dispatch(hl.dsp.exec_cmd(service))
  end

  -- Lanzar scratchpads en segundo plano
  hl.dispatch(hl.dsp.exec_cmd(progs.monitor)) -- Usa el comando completo
  hl.dispatch(hl.dsp.exec_cmd(progs.music))
  hl.dispatch(hl.dsp.exec_cmd(progs.notes))
end)

hl.on("hyprland.shutdown", function()
  -- Lógica de limpieza, guardado de estado o kill de procesos persistentes
end)
