local clipboard = require("img-clip.clipboard")
local markup = require("img-clip.markup")
local config = require("img-clip.config")
local util = require("img-clip.util")
local fs = require("img-clip.fs")

local clip_cmd = nil

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

---@private
---@param opts? table
---@return boolean
local paste_as_file = function(opts)
  -- get the file path
  local file_path = fs.get_file_path("png", opts)
  if not file_path then
    util.error("Could not determine file path.")
    return false
  end

  -- mkdir if not exists
  local dir_path = vim.fn.fnamemodify(file_path, ":h")
  if not fs.mkdirp(dir_path) then
    util.error("Could not create directories.")
    return false
  end

  -- save image to specified file path
  if not clipboard.save_image(clip_cmd, file_path) then
    util.error("Could not save image to disk.")
    return false
  end

  -- get the markup for the image
  if not markup.insert_markup(file_path, opts) then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

---@private
---@param ft string
---@return boolean
local language_supports_base64_embedding = function(ft)
  return ft == "markdown" or ft == "md" or ft == "rmd" or ft == "wiki" or ft == "vimwiki"
end

---@private
---@param ft string
---@return string
local get_base64_prefix = function(ft)
  if ft == "markdown" or ft == "md" or ft == "rmd" or ft == "wiki" or ft == "vimwiki" then
    return "data:image/png;base64,"
  end

  return ""
end

---@private
---@param opts? table
---@return boolean
local embed_image_as_base64 = function(opts)
  -- get the base64 string
  local base64 = clipboard.get_base64_encoded_image(clip_cmd)
  if not base64 then
    util.error("Could not get base64 string.")
    return false
  end

  -- check if base64 string is too long - max_base64_size is in KB
  if string.len(base64) > config.get_option("max_base64_size", opts) * 1024 then
    return false
  end

  local prefix = get_base64_prefix(vim.bo.filetype)

  -- get the markup for the image
  if not markup.insert_markup(prefix .. base64, opts) then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

---@param opts? table
---@return boolean
M.pasteImage = function(opts)
  -- get the clipboard command
  -- but only the first time the function is called
  -- unless the clipboard command is nil, then retry
  if not clip_cmd then
    clip_cmd = clipboard.get_clip_cmd()
    if not clip_cmd then
      util.error("Could not get clipboard command. See :checkhealth img-clip.")
      return false
    end
  end

  -- check if clipboard content is an image
  if not clipboard.content_is_image(clip_cmd) then
    util.warn("Clipboard content is not an image.")
    return false
  end

  -- paste as base 64 if enabled and supported, otherwise paste as file
  if config.get_option("embed_image_as_base64", opts) and language_supports_base64_embedding(vim.bo.filetype) then
    if embed_image_as_base64(opts) then
      return true
    end
  end

  -- paste as file otherwise
  return paste_as_file(opts)
end

return M
