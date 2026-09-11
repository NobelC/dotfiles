local M = {}

-- Modificador principal
M.mainMod = "SUPER"

-- Comandos de aplicaciones
M.terminal = "ghostty"
M.fileManager = "ghostty -e yazi"
M.menu = "wofi --show drun"
M.browser = "firefox"
M.notes = "obsidian"
M.music = "spotify"
M.monitor = "ghostty --title=Monitor -e bash -c 'btop; exec bash'"
M.audioControl = "hyprpwcenter"
M.colorPicker = "hyprpicker -a"

-- Nombres de scratchpads
M.scratchpad_monitor = "monitor"
M.scratchpad_music = "music"
M.scratchpad_notes = "notes"

return M
