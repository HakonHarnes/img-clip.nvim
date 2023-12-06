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
  local path_separator = package.config:sub(1, 1)
  local str_without_ext = str:gsub("%.[^" .. path_separator .. "]-$", "")
  return str_without_ext .. "." .. ext
end

M.get_filename_from_filepath = function(filepath)
  local path_separator = package.config:sub(1, 1)
  local filename = filepath:match("([^" .. path_separator .. "]+)$")
  return filename
end

M.get_dir_path_from_filepath = function(filepath)
  local path_separator = package.config:sub(1, 1)
  local dir_path = filepath:match("(.*" .. path_separator .. ").*")
  return dir_path
end

M.get_filepath = function(opts)
  local path_separator = package.config:sub(1, 1)

  local config_dir_path = config.get_option("dir_path", opts)
  local config_filename = os.date(config.get_option("filename", opts))

  local dir_path

  if config.get_option("absolute_path", opts) then
    local cwd = vim.fn.getcwd()
    dir_path = vim.fn.resolve(cwd .. path_separator .. config_dir_path)
  else
    dir_path = vim.fn.resolve(config_dir_path)
  end

  local filepath
  if config.get_option("prompt_for_filename", opts) then
    if config.get_option("include_filepath_in_prompt", opts) then
      local default_filepath = dir_path .. path_separator
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
        filepath = vim.fn.resolve(dir_path .. path_separator .. input_filename)
      end
    end
  end

  if not filepath then
    filepath = vim.fn.resolve(dir_path .. path_separator .. config_filename)
  end

  filepath = M.add_file_ext(filepath, "png")
  return filepath
end

M.mkdirs = function(filepath)
  local is_windows = M.has("win32" or M.has("wsl"))

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

M.split_lines = function(template)
  local lines = vim.split(template, "\n")

  if lines[1] and lines[1]:match("^%s*$") then
    table.remove(lines, 1)
  end

  if lines[#lines] and lines[#lines]:match("^%s*$") then
    table.remove(lines)
  end

  return lines
end

M.get_new_row = function(row, lines)
  for i, line in ipairs(lines) do
    if line:match("$CURSOR") then
      return row + i, line, i
    end
  end

  return row + #lines, lines[#lines], #lines
end

M.get_new_col = function(line)
  local cursor_pos = line:find("$CURSOR")
  if cursor_pos then
    return cursor_pos - 1
  end

  return string.len(line) - 1
end

M.insert_markup = function(filepath, opts)
  local template = config.get_option("template", opts)
  if not template then
    return false
  end

  local filename = M.get_filename_from_filepath(filepath)

  template = template:gsub("$FILEPATH", filepath)
  template = template:gsub("$FILENAME", filename)
  local lines = M.split_lines(template)

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local cur_row = cur_pos[1]

  local new_row, line, index = M.get_new_row(cur_row, lines)
  local new_col = M.get_new_col(line)

  lines[index] = line:gsub("$CURSOR", "")

  vim.api.nvim_put(lines, "l", true, true)
  vim.api.nvim_win_set_cursor(0, { new_row, new_col })

  return true
end

return M
