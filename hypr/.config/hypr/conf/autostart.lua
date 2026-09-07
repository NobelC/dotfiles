local services = {
  "waybar",
  "hyprpaper",
  "nm-applet",
}

hl.on("hyprland.start", function()
  for _, service in ipairs(services) do
    hl.dispatch(hl.dsp.exec_cmd(service))
  end
end)

hl.on("hyprland.shutdown", function()
  -- Lógica de limpieza, guardado de estado o kill de procesos persistentes
end)
