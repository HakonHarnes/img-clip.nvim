local clipoard = require("img-clip.clipboard")
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
---@return string[]
local function split_path(str)
  local result = {}
  local pattern = "[^/\\]+"

  for part in string.gmatch(str, pattern) do
    table.insert(result, part)
  end

  return result
end

---@param target string
---@param start? string
---@return string relative_path
M.relpath = function(target, start)
  start = start or vim.fn.getcwd()

  target = vim.fn.fnamemodify(target, ":p")
  start = vim.fn.fnamemodify(start, ":p")

  local target_parts = split_path(target)
  local start_parts = split_path(start)

  -- find out where the paths diverge
  local common_length = 0
  for i = 1, math.min(#start_parts, #target_parts) do
    if start_parts[i] == target_parts[i] then
      common_length = i
    else
      break
    end
  end

  -- calculate how many directories we have to go up
  local result = {}
  for _ = common_length + 1, #start_parts do
    table.insert(result, "..")
  end

  -- add the non-common parts of the target path
  for i = common_length + 1, #target_parts do
    table.insert(result, target_parts[i])
  end

  return table.concat(result, M.sep)
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
  local config_dir_path = config.get_opt("dir_path", opts)
  local config_file_name = os.date(config.get_opt("file_name", opts))

  local dir_path = config_dir_path
  if config.get_opt("relative_to_current_file", opts) then
    local current_file_path = vim.fn.expand("%:.:h")
    if current_file_path ~= "." and current_file_path ~= "" then
      dir_path = current_file_path .. M.sep .. config_dir_path
    end
  end

  if config.get_opt("use_absolute_path", opts) then
    dir_path = vim.fn.fnamemodify(dir_path, ":p")
  end

  dir_path = M.normalize_path(dir_path)

  local file_path
  if config.get_opt("prompt_for_file_name", opts) then
    if config.get_opt("show_dir_path_in_prompt", opts) then
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
        prompt = "File name: ",
        completion = "file",
      })
      if input_filename and input_filename ~= "" then
        file_path = dir_path .. input_filename
      end
    end
  end

  -- use default path and filename if none was provided
  if not file_path then
    file_path = dir_path .. config_file_name
  end

  -- add file ext
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

---@param src string
---@param dest string
---@return string | nil output
---@return number exit_code
M.copy_file = function(src, dest)
  return util.execute(string.format("cp '%s' '%s'", src, dest))
end

---@param file_path string
---@return string | nil
M.get_base64_encoded_image = function(file_path)
  local cmd = clipoard.get_clip_cmd()

  -- Windows
  if cmd == "powershell.exe" then
    local command = string.format([[[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes('%s'))]], file_path)
    local output, exit_code = util.execute(command)
    if exit_code == 0 then
      return output:gsub("\r\n", ""):gsub("\n", ""):gsub("\r", "")
    end

  -- Linux/MacOS
  else
    local command = string.format("base64 '%s' | tr -d '\n'", file_path)
    local output, exit_code = util.execute(command)
    if exit_code == 0 then
      return output
    end
  end

  return nil
end

return M
