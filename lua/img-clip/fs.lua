local config = require("img-clip.config")
local util = require("img-clip.util")

local M = {}

---@type string
M.sep = package.config:sub(1, 1)

---@param path string
---@return string
M.normalize_path = function(path)
  return vim.fn.simplify(path):gsub(M.sep .. "$", "") .. M.sep
end

---@param str string
---@param ext string
---@return string
M.add_file_ext = function(str, ext)
  str = vim.fn.fnamemodify(str, ":r")
  return str .. "." .. ext
end

---@param ext string
---@param opts? table
---@return string
M.get_file_path = function(ext, opts)
  local config_dir_path = config.get_option("dir_path", opts)
  local config_filename = os.date(config.get_option("filename", opts))

  local dir_path = config_dir_path
  if config.get_option("absolute_path", opts) then
    dir_path = vim.fn.fnamemodify(dir_path, ":p")
  end

  dir_path = M.normalize_path(dir_path)

  local file_path
  if config.get_option("prompt_for_filename", opts) then
    if config.get_option("include_path_in_prompt", opts) then
      local input_file_path = util.input({
        prompt = "File path: ",
        default = dir_path,
        completion = "file",
      })
      if input_file_path and input_file_path ~= "" and input_file_path ~= dir_path then
        file_path = input_file_path
      end
    else
      local input_filename = util.input({
        prompt = "Filename: ",
        completion = "file",
      })
      if input_filename and input_filename ~= "" then
        file_path = dir_path .. input_filename
      end
    end
  end

  -- use default path and filename if none was provided
  if not file_path then
    file_path = dir_path .. config_filename
  end

  file_path = M.add_file_ext(file_path, ext)
  return file_path
end

---@param dir string
---@param mode number
---@return boolean
M.mkdirp = function(dir, mode)
  dir = vim.fn.resolve(dir)
  mode = mode or 493

  local mod = ""
  local path = dir

  while vim.fn.isdirectory(path) == 0 do
    mod = mod .. ":h"
    path = vim.fn.fnamemodify(dir, mod)
  end

  while mod ~= "" do
    mod = mod:sub(3)
    path = vim.fn.fnamemodify(dir, mod)

    if not vim.loop.fs_mkdir(path, mode) then
      return false
    end
  end

  return true
end

return M
