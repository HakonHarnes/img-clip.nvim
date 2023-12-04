local util = require("img-clip.util")
local config = require("img-clip.config")
local clipboard = require("img-clip.clipboard")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local cmd = nil

M.pasteImage = function()
  if not cmd then
    cmd = clipboard.get_cmd()
    if not cmd then
      return
    end
  end

  -- checks if clipboard content is an image
  local is_image = clipboard.check_if_content_is_image(cmd)
  if not is_image then
    return util.warn("Clipboard content is not an image.")
  end
  util.debug("Clipboard content is an image.")
end

M.pasteImage()

return M
