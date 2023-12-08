local util = require("img-clip.util")

local M = {}

---@return string | nil
M.get_clip_cmd = function()
  -- Windows
  if util.has("win32") or util.has("wsl") then
    if util.executable("powershell.exe") then
      return "powershell.exe"
    else
      util.error("Dependency check failed. 'powershell.exe' is not installed.")
      return nil
    end

    -- Linux (X11)
  elseif os.getenv("DISPLAY") then
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
    if util.executable("pngpaste") then
      return "pngpaste"
    elseif util.executable("osascript") then
      return "osascript"
    else
      util.error("Dependency check failed. 'osascript' is not installed.")
      return nil
    end

    -- Other OS
  else
    util.error("Operating system is not supported.")
    return nil
  end
end

---@param cmd string
---@return boolean
M.check_if_content_is_image = function(cmd)
  -- Linux (X11)
  if cmd == "xclip" then
    local output = util.execute("xclip -selection clipboard -t TARGETS -o")
    return output ~= nil and output:find("image/png") ~= nil

    -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    local output = util.execute("wl-paste --list-types")
    return output ~= nil and output:find("image/png") ~= nil

    -- MacOS (pngpaste) which is faster than osascript
  elseif cmd == "pngpaste" then
    local _, exit_code = util.execute("pngpaste -")
    return exit_code == 0

    -- MacOS (osascript) as a fallback
  elseif cmd == "osascript" then
    local output = util.execute("osascript -e 'clipboard info'")
    return output ~= nil and output:find("class PNGf") ~= nil

    -- Windows
  elseif cmd == "powershell.exe" then
    local output = util.execute('powershell.exe -command "Get-Clipboard -Format Image"')
    return output ~= nil and output:find("ImageFormat") ~= nil
  end

  return false
end

---@param cmd string
---@param file_path string
---@return boolean
M.save_clipboard_image = function(cmd, file_path)
  -- Linux (X11)
  if cmd == "xclip" then
    local command = string.format('xclip -selection clipboard -o -t image/png > "%s"', file_path)
    local _, exit_code = util.execute(command)
    return exit_code == 0

    -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    local command = string.format('wl-paste --type image/png > "%s"', file_path)
    local _, exit_code = util.execute(command)
    return exit_code == 0

    -- MacOS (pngpaste) which is faster than osascript
  elseif cmd == "pngpaste" then
    local command = string.format('pngpaste "%s"', file_path)
    local _, exit_code = util.execute(command)
    return exit_code == 0

    -- MacOS (osascript) as a fallback
  elseif cmd == "osascript" then
    local command = string.format(
      "osascript -e 'set theFile to (open for access POSIX file \"%s\" with write permission)' -e 'try' -e 'write (the clipboard as «class PNGf») to theFile' -e 'end try' -e 'close access theFile'",
      file_path
    )
    local _, exit_code = util.execute(command)
    return exit_code == 0

    -- Windows
  elseif cmd == "powershell.exe" then
    local command = string.format(
      'powershell.exe -command \'$content = Get-Clipboard -Format Image; $content.Save("%s", "png")\'',
      file_path
    )
    local _, exit_code = util.execute(command)
    return exit_code == 0
  end

  return false
end

return M
