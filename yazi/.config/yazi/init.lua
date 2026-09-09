-- ~/dotfiles/yazi/.config/yazi/init.lua

-- Enable shell integration for cd on quit
function Linemode:size_and_mtime()
  local time = math.floor(self.file.cha.mtime or 0)
  if time == 0 then
    time = ""
  elseif os.date("%Y", time) == os.date("%Y") then
    time = os.date("%b %d %H:%M", time)
  else
    time = os.date("%b %d  %Y", time)
  end

  local size = self.file:size()
  return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

-- Custom linemode showing file size and modification time
ya.manager_emit("setup", {
  linemode = "size_and_mtime",
})
