local util = require("img-clip.util")

local M = {}

---@return string | nil
M.get_clip_cmd = function()
  -- Windows
  if (util.has("win32") or util.has("wsl")) and util.executable("powershell.exe") then
    return "powershell.exe"

  -- Linux (Wayland)
  elseif os.getenv("WAYLAND_DISPLAY") and util.executable("wl-paste") then
    return "wl-paste"

  -- Linux (X11)
  elseif os.getenv("DISPLAY") and util.executable("xclip") then
    return "xclip"

  -- MacOS
  elseif util.has("mac") then
    if util.executable("pngpaste") then
      return "pngpaste"
    elseif util.executable("osascript") then
      return "osascript"
    end
  end

  return nil
end

---@param cmd string
---@return boolean
M.content_is_image = function(cmd)
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
  -- TODO: Add correct quotes aroudn class PNGf
  elseif cmd == "osascript" then
    local output = util.execute("osascript -e 'clipboard info'")
    return output ~= nil and output:find("class PNGf") ~= nil

  -- Windows
  elseif cmd == "powershell.exe" then
    local output = util.execute("powershell.exe Get-Clipboard -Format Image")
    return output ~= nil and output:find("ImageFormat") ~= nil
  end

  return false
end

---@param cmd string
---@param file_path string
---@return boolean
M.save_image = function(cmd, file_path)
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
      [[osascript -e 'set theFile to (open for access POSIX file "%s" with write permission)' ]]
        .. [[-e 'try' -e 'write (the clipboard as «class PNGf») to theFile' -e 'end try' ]]
        .. [[-e 'close access theFile']],
      file_path
    )
    local _, exit_code = util.execute(command)
    return exit_code == 0

  -- Windows
  elseif cmd == "powershell.exe" then
    local command = string.format([[powershell.exe "(Get-Clipboard -Format Image).Save('%s')"]], file_path)
    local _, exit_code = util.execute(command)
    return exit_code == 0
  end

  return false
end

M.get_base64_encoded_image = function(cmd)
  -- Linux (X11)
  if cmd == "xclip" then
    local output, exit_code = util.execute("xclip -selection clipboard -o -t image/png | base64 | tr -d '\n'")
    if exit_code == 0 then
      return output
    end

  -- Linux (Wayland)
  elseif cmd == "wl-paste" then
    local output, exit_code = util.execute("wl-paste --type image/png | base64 | tr -d '\n'")
    if exit_code == 0 then
      return output
    end

  -- MacOS (pngpaste)
  elseif cmd == "pngpaste" then
    local output, exit_code = util.execute("pngpaste - | base64 | tr -d '\n'")
    if exit_code == 0 then
      return output
    end

  -- MacOS (osascript)
  elseif cmd == "osascript" then
    local output, exit_code = util.execute(
      [[osascript -e 'set theFile to (open for access POSIX file "/tmp/image.png" with write permission)' ]]
        .. [[-e 'try' -e 'write (the clipboard as «class PNGf») to theFile' -e 'end try' -e 'close access theFile'; ]]
        .. [[cat /tmp/image.png | base64 | tr -d "\n" ]]
    )
    if exit_code == 0 then
      return output
    end

  -- Windows native
  elseif cmd == "powershell.exe" and util.has("win32") then
    local output, exit_code = util.execute(
      [[powershell.exe $ms = New-Object System.IO.MemoryStream; (Get-Clipboard -Format Image)]]
        .. [[.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); [System.Convert]::ToBase64String($ms.ToArray())]]
    )
    if exit_code == 0 then
      return output:gsub("\r\n", ""):gsub("\n", ""):gsub("\r", "")
    end

  -- Windows WSL
  elseif cmd == "powershell.exe" and util.has("wsl") then
    local output, exit_code = util.execute(
      [[powershell.exe '$ms = New-Object System.IO.MemoryStream; (Get-Clipboard -Format Image)]]
        .. [[.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); [System.Convert]::ToBase64String($ms.ToArray())']]
    )
    if exit_code == 0 then
      return output:gsub("\r\n", ""):gsub("\n", ""):gsub("\r", "")
    end
  end

  return nil
end

return M
