local util = require("img-clip.util")

local M = {}

M.get_clip_cmd = function()
  -- Linux (X11)
  if os.getenv("DISPLAY") then
    if util.executable("xclip") then
      return "xclip"
    else
      util.error("Dependency check failed. 'xclip' is not installed.")
      return nil
    end

  -- Linux (Wayland)
  elseif os.getenv("WAYLAND_DISPLAY") then
    if util.executable("wl-paste") then
      return "wl-paste"
    else
      util.error("Dependency check failed. 'wl-clipboard' is not installed.")
      return nil
    end

  -- MacOS
  elseif util.has("mac") then
    if util.executable("osascript") then
      return "osascript"
    else
      util.error("Dependency check failed. 'osascript' is not installed.")
      return nil
    end

  -- Windows
  elseif util.has("win32") or util.has("wsl") then
    if util.executable("powershell.exe") then
      return "powershell.exe"
    else
      util.error("Dependency check failed. 'powershell.exe' is not installed.")
      return nil
    end

  -- Other OS
  else
    util.error("Operating system is not supported.")
    return nil
  end
end

M.check_if_content_is_image = function(cmd)
  -- Linux (X11)
  if cmd == "xclip" then
    local output = util.execute("xclip -selection clipboard -t TARGETS -o")
    if not output then
      return false
    elseif string.find(output, "image/png") then
      return true
    else
      return false
    end

  -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    -- TODO: Implement clipboard check for Wayland
    return false

  -- MacOS
  elseif cmd == "osascript" then
    -- TODO: Implement clipboard check for MacOS
    return false

  -- Windows
  elseif cmd == "powershell.exe" then
    -- TODO: Implement clipboard check for Windows
    return false
  end
end

M.save_clipboard_image = function(cmd, file_path)
  -- Linux (X11)
  if cmd == "xclip" then
    local command = string.format('xclip -selection clipboard -o -t image/png > "%s"', file_path)
    local exit_code = os.execute(command)
    return exit_code == 0

  -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    -- TODO: Implement clipboard check for Wayland
    return false

  -- MacOS
  elseif cmd == "osascript" then
    -- TODO: Implement clipboard check for MacOS
    return false

  -- Windows
  elseif cmd == "powershell.exe" then
    -- TODO: Implement clipboard check for Windows
    return false
  end
end

return M
