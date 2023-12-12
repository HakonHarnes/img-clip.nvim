local clipboard = require("img-clip.clipboard")
local markup = require("img-clip.markup")
local config = require("img-clip.config")
local util = require("img-clip.util")
local fs = require("img-clip.fs")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local clip_cmd = nil

---@param opts? table
---@return boolean
M.pasteImage = function(opts)
  if not clip_cmd then
    clip_cmd = clipboard.get_clip_cmd()
    if not clip_cmd then
      util.error("Could not get clipboard command. See :checkhealth img-clip.")
      return false
    end
  end

  -- check if clipboard content is an image
  local is_image = clipboard.check_if_content_is_image(clip_cmd)
  if not is_image then
    util.warn("Clipboard content is not an image.")
    return false
  end

  -- paste as base 64 if enabled and supported, otherwise paste as file
  if config.get_option("embed_image_as_base64", opts) and M._language_supports_base64_embedding(vim.bo.filetype) then
    if M._embed_image_as_base64(opts) then
      return true
    end
  end

  -- paste as file otherwise
  return M._paste_as_file(opts)
end

---@param opts? table
---@return boolean
M._paste_as_file = function(opts)
  -- get the file path
  local file_path = fs.get_file_path("png", opts)
  if not file_path then
    util.error("Could not determine file path.")
    return false
  end

  -- mkdir if not exists
  local dir_path = vim.fn.fnamemodify(file_path, ":h")
  local dir_ok = fs.mkdirp(dir_path)
  if not dir_ok then
    util.error("Could not create directories.")
    return false
  end

  -- save image to specified file path
  local save_ok = clipboard.save_clipboard_image(clip_cmd, file_path)
  if not save_ok then
    util.error("Could not save image to disk.")
    return false
  end

  -- get the markup for the image
  local markup_ok = markup.insert_markup(file_path, opts)
  if not markup_ok then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

---@param ft string
---@return boolean
M._language_supports_base64_embedding = function(ft)
  return ft == "markdown" or ft == "rmd"
end

---@param opts? table
---@return boolean
M._embed_image_as_base64 = function(opts)
  -- get the base64 string
  local base64 = clipboard.get_clipboard_image_base64(clip_cmd)
  if not base64 then
    util.error("Could not get base64 string.")
    return false
  end

  -- check if base64 string is too long - max_base64_size is in KB
  if string.len(base64) > config.get_option("max_base64_size", opts) * 1024 then
    return false
  end

  local prefix = M._get_base64_prefix(vim.bo.filetype)

  -- get the markup for the image
  local markup_ok = markup.insert_markup(prefix .. base64, opts)
  if not markup_ok then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

---@param ft string
---@return string
M._get_base64_prefix = function(ft)
  if ft == "markdown" or ft == "rmd" then
    return "data:image/png;base64,"
  end

  return ""
end

M._handle_paste = function(input)
  if util._is_image_url(input) then
    return M._handle_image_url(input)
  end
  if util._is_image_path(input) then
    return M._handle_image_path(input)
  end

  return false
end

M._handle_image_url = function(url)
  -- download the image in the link and insert the markup
  if config.get_option("download_image_from_link") then
    -- get the file path
    local file_path = fs.get_file_path("png")
    if not file_path then
      util.error("Could not determine file path.")
      return false
    end

    -- mkdir if not exists
    local dir_path = vim.fn.fnamemodify(file_path, ":h")
    local dir_ok = fs.mkdirp(dir_path)
    if not dir_ok then
      util.error("Could not create directories.")
      return false
    end

    -- download image to specified file path
    local _, exit_code = util.execute(string.format("curl -o '%s' '%s'", file_path, url))
    if exit_code ~= 0 then
      util.error("Could not download image.")
      return false
    end

    -- get the markup for the image
    local markup_ok = markup.insert_markup(file_path)
    if not markup_ok then
      util.error("Could not insert markup code.")
      return false
    end

  -- just insert the url as markup
  else
    -- get the markup for the image
    local markup_ok = markup.insert_markup(url)
    if not markup_ok then
      util.error("Could not insert markup code.")
      return false
    end
  end
  return true
end

M._handle_image_path = function(path)
  -- copy the image to the dir_path and insert the markup
  if config.get_option("copy_dropped_files_to_dir_path") then
    -- get the file path
    local file_path = fs.get_file_path("png")
    if file_path then
      -- mkdir if not exists
      local dir_path = vim.fn.fnamemodify(file_path, ":h")
      local dirs_created = fs.mkdirp(dir_path)
      if not dirs_created then
        util.error("Could not create directories.")
        return false
      end

      -- copy image to specified file path
      local copy_ok = fs.copy_file(path, file_path)
      if not copy_ok then
        util.error("Could not copy image.")
        return false
      end

      path = file_path
    end
  end

  -- get the markup for the image
  local markup_ok = markup.insert_markup(path)
  if not markup_ok then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

return M
