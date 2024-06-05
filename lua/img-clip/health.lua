local util = require("img-clip.util")

local M = {}

local ok = vim.health.ok or vim.health.report_ok
local start = vim.health.start or vim.health.report_start
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error

M.check = function()
  start("img-clip.nvim")

  -- Linux (Wayland)
  if os.getenv("WAYLAND_DISPLAY") then
    if util.executable("wl-copy") then
      ok("`wl-clipboard` is installed")
    else
      error("`wl-clipboard` is not installed")
    end

  -- Linux (X11)
  elseif os.getenv("DISPLAY") then
    if util.executable("xclip") then
      ok("`xclip` is installed")
    else
      error("`xclip` is not installed")
    end

  -- MacOS
  elseif util.has("mac") then
    if util.executable("osascript") then
      ok("`osascript` is installed")
    else
      error("`osascript` is not installed")
    end
    if util.executable("pngpaste") then
      ok("`pngpaste` is installed")
    else
      warn("`pngpaste` is not installed")
    end

  -- Windows
  elseif util.has("win32") or util.has("wsl") then
    if util.executable("powershell.exe") then
      ok("`powershell.exe` is installed")
    else
      error("`powershell.exe` is not installed")
    end

  -- Other OS
  else
    error("Operating system is not supported")
  end
end

return M
