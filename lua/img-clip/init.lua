local util = require("img-clip.util")
local config = require("img-clip.config")
local clipboard = require("img-clip.clipboard")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local clip_cmd = nil

M.pasteImage = function(opts)
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
  local filepath = util.get_filepath(opts)
  if not filepath then
    return util.error("Could not determine filepath.")
  end

  -- mkdir if not exists
  local dir_ok = util.mkdirs(filepath)
  if not dir_ok then
    return util.error("Could not create directories.")
  end

  -- save image to specified file path
  local save_ok = clipboard.save_clipboard_image(clip_cmd, filepath)
  if not save_ok then
    return util.error("Could not save image to disk.")
  end

  -- get the markup for the image
  local markup_ok = util.insert_markup(filepath, opts)
  if not markup_ok then
    return util.error("Could not insert markup code.")
  end
end

return M
