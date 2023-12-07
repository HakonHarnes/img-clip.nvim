local config = require("img-clip.config")
local util = require("img-clip.util")

local M = {}

M.sep = package.config:sub(1, 1)

M.add_file_ext = function(str, ext)
  local str_without_ext = str:gsub("%.[^" .. M.sep .. "]-$", "")
  return str_without_ext .. "." .. ext
end

M.get_filename_from_filepath = function(filepath)
  local filename = filepath:match("([^" .. M.sep .. "]+)$")
  return filename
end

M.get_dir_path_from_filepath = function(filepath)
  local dir_path = filepath:match("(.*" .. M.sep .. ").*")
  return dir_path
end

M.get_filepath = function(opts)
  local config_dir_path = config.get_option("dir_path", opts)
  local config_filename = os.date(config.get_option("filename", opts))

  local dir_path

  if config.get_option("absolute_path", opts) then
    local cwd = vim.fn.getcwd()
    dir_path = vim.fn.resolve(cwd .. M.sep .. config_dir_path)
  else
    dir_path = vim.fn.resolve(config_dir_path)
  end

  local filepath
  if config.get_option("prompt_for_filename", opts) then
    if config.get_option("include_filepath_in_prompt", opts) then
      local default_filepath = dir_path .. M.sep
      local input_filepath = M.input({
        prompt = "Filepath: ",
        default = default_filepath,
        completion = "file",
      })
      if input_filepath ~= "" and input_filepath ~= default_filepath then
        filepath = vim.fn.resolve(input_filepath)
      end
    else
      local input_filename = M.input({ prompt = "Filename: ", completion = "file" })
      if input_filename ~= "" then
        filepath = vim.fn.resolve(dir_path .. M.sep .. input_filename)
      end
    end
  end

  if not filepath then
    filepath = vim.fn.resolve(dir_path .. M.sep .. config_filename)
  end

  filepath = M.add_file_ext(filepath, "png")
  return filepath
end

M.mkdirs = function(filepath)
  local is_windows = util.has("win32" or util.has("wsl"))

  local dir_path = M.get_dir_path_from_filepath(filepath)
  if not dir_path then
    return
  end -- if no directory in path, return

  local command
  if is_windows then
    command = string.format('mkdir "%s"', dir_path)
  else
    command = string.format('mkdir -p "%s"', dir_path)
  end

  local exit_code = os.execute(command)
  return exit_code == 0
end

return M
