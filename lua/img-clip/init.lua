local util = require("img-clip.util")
local config = require("img-clip.config")
local clipboard = require("img-clip.clipboard")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local clip_cmd = nil

M.pasteImage = function()
  if not clip_cmd then
    clip_cmd = clipboard.get_clip_cmd()
    if not clip_cmd then
      return
    end
  end

  -- check if clipboard content is an image
  local is_image = clipboard.check_if_content_is_image(clip_cmd)
  if not is_image then
    return util.warn("Clipboard content is not an image.")
  end

  -- get the file path
  local filepath = util.get_filepath()
  if not filepath then
    return util.error("Could not determine filepath.")
  end

  -- save image to specified file path
  local success = clipboard.save_clipboard_image(clip_cmd, filepath)
  if not success then
    return util.error("Could not save image to disk.")
  end
end

M.pasteImage()

return M
