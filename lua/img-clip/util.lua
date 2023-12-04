local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
end

M.has = function(feature)
  return vim.fn.has(feature) == 1
end

M.warn = function(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "img-clip" })
end

M.error = function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "img-clip" })
end

M.debug = function(msg)
  if config.options.debug then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "img-clip" })
  end
end

M.get_cmd = function()
  -- Linux (X11)
  if os.getenv("DISPLAY") then
    if M.executable("xclip") then
      return "xclip"
    else
      M.error("Dependency check failed. 'xclip' is not installed.")
      return nil
    end

  -- Linux (Wayland)
  elseif os.getenv("WAYLAND_DISPLAY") then
    if M.executable("wl-copy") then
      return "wl-copy"
    else
      M.error("Dependency check failed. 'wl-clipboard' is not installed.")
      return nil
    end

  -- MacOS
  elseif M.has("mac") then
    if M.executable("osascript") then
      return "osascript"
    else
      M.error("Dependency check failed. 'osascript' is not installed.")
      return nil
    end

  -- Windows
  elseif M.has("win32") or M.has("wsl") then
    if M.executable("powershell.exe") then
      return "powershell.exe"
    else
      M.error("Dependency check failed. 'powershell.exe' is not installed.")
      return nil
    end

  -- Other OS
  else
    M.error("Operating system is not supported.")
    return nil
  end
end

return M
