local markup = require("img-clip.markup")
local config = require("img-clip.config")
local util = require("img-clip.util")
local fs = require("img-clip.fs")

local M = {}

---@private
---@param url string
---@return boolean status
local handle_image_url = function(url)
  -- download the image in the link and insert the markup
  if config.get_option("drag_and_drop.download_images") then
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
    if not markup.insert_markup(file_path) then
      util.error("Could not insert markup code.")
      return false
    end
  else
    -- get the markup for the image
    if not markup.insert_markup(url) then
      util.error("Could not insert markup code.")
      return false
    end
  end
  return true
end

---@private
---@param path string
---@return boolean status
local handle_image_path = function(path)
  -- copy the image to the dir_path and insert the markup
  if config.get_option("drag_and_drop.copy_images") then
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
  if not markup.insert_markup(path) then
    util.error("Could not insert markup code.")
    return false
  end

  return true
end

---@private
---@param str string
---@return string
local function sanitize_input(str)
  str = str:match("^%s*(.-)%s*$") -- remove leading and trailing whitespace
  str = str:match('^"?(.-)"?$') -- remove double quotes
  str = str:match("^'?(.-)'?$") -- remove single quotes
  str = str:gsub("file://", "") -- remove "file://"
  return str
end

---@param input string
---@return boolean status
M.handle_paste = function(input)
  input = sanitize_input(input)

  if util.is_image_url(input) then
    return handle_image_url(input)
  elseif util.is_image_path(input) then
    return handle_image_path(input)
  end

  -- input was not handled -- continue with the default vim.paste()
  return false
end

return M
