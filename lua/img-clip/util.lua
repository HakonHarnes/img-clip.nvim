local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
end

M.execute = function(cmd)
  M.debug("Executing: " .. cmd)

  local handle = io.popen(cmd)
  if not handle then
    M.error("Failed to execute command: " .. cmd)
    return nil, nil, nil, nil
  end

  local output = handle:read("*a")
  handle:close()

  return output
end

M.has = function(feature)
  return vim.fn.has(feature) == 1
end

M.warn = function(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "img-clip" })
end

M.error = function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "img-clip" })
end

M.debug = function(msg)
  if config.options.debug then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "img-clip" })
  end
end

M.input = function(args)
  local _, output = pcall(function()
    return vim.fn.input(args)
  end)

  return output
end

M.add_file_ext = function(str, ext)
  if not str:match("%." .. ext .. "$") then
    if not ext:match("^%.") then
      ext = "." .. ext
    end
    str = str .. ext
  end

  return str
end

M.get_filepath = function()
  local path_separator = package.config:sub(1, 1)

  local config_dir_path = config.get_option("dir_path")
  local config_filename = os.date(config.get_option("filename"))

  local filepath
  if config.get_option("prompt_for_filename") then
    if config.get_option("include_filepath_in_prompt") then
      local input_filepath = M.input({
        prompt = "Filepath: ",
        default = vim.fn.resolve(config_dir_path) .. path_separator,
        completion = "file",
      })
      if input_filepath then
        filepath = vim.fn.resolve(input_filepath)
      end
    else
      local input_filename = vim.fn.input({ prompt = "Filename: ", completion = "file" })
      if input_filename then
        filepath = vim.fn.resolve(config_dir_path .. path_separator .. input_filename)
      end
    end
  end

  if not filepath then
    filepath = vim.fn.resolve(config_dir_path .. path_separator .. config_filename)
  end

  filepath = M.add_file_ext(filepath, "png")
  return filepath
end

M.mkdirs = function(filepath)
  local path_separator = package.config:sub(1, 1)
  local is_windows = M.has("win32" or M.has("wsl"))

  -- get the dir_path (filepath without filename)
  local dir_path = filepath:match("(.*" .. path_separator .. ").*")
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
