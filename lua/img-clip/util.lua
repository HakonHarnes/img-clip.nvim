local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
end

---@param cmd string
---@param powershell? boolean
---@return string | nil output
---@return number exit_code
M.execute = function(cmd, powershell)
  local shell = vim.o.shell:lower()
  local command

  -- execute command directly if not powershell
  if not powershell then
    command = cmd

  -- execute command directly if shell is powershell or pwsh
  elseif shell:match("powershell") or shell:match("pwsh") then
    command = cmd

  -- WSL requires the command to have the format:
  -- powershell.exe -Command 'command "path/to/file"'
  elseif M.has("wsl") then
    command = "powershell.exe -NoProfile -Command '" .. cmd:gsub("'", '"') .. "'"

  -- cmd.exe requires the command to have the format:
  -- powershell.exe -Command "command 'path/to/file'"
  else
    command = 'powershell.exe -NoProfile -Command "' .. cmd:gsub('"', "'") .. '"'
  end

  local output = vim.fn.system(command)
  local exit_code = vim.v.shell_error

  if config.get_option("debug") then
    print("Shell: " .. shell)
    print("Command: " .. command)
    print("Exit code: " .. exit_code)
    print("Output: " .. output)
  end

  return output, exit_code
end

---@param feature string
M.has = function(feature)
  return vim.fn.has(feature) == 1
end

---@param msg string
M.warn = function(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "img-clip" })
end

---@param msg string
M.error = function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "img-clip" })
end

---@param msg string
M.debug = function(msg)
  if config.options.debug then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "img-clip" })
  end
end

---@param args string
M.input = function(args)
  local completed, output = pcall(function()
    return vim.fn.input(args)
  end)

  if not completed then
    return nil
  end

  return output
end

---@param str string
---@return boolean
M.is_image_url = function(str)
  -- return early if not a valid url to a subdomain
  if not str:match("^https?://[^/]+/[^.]+") then
    return false
  end

  -- assume its a valid image link if it the url ends with an extension
  if str:match("%.png$") or str:match("%.jpg$") or str:match("%.jpeg$") then
    return true
  end

  -- send a head request to the url and check content type
  local command = string.format("curl -s -I -w '%%{content_type}' '%s'", str)
  local output, exit_code = M.execute(command)
  return exit_code == 0 and output ~= nil and (output:match("image/png") ~= nil or output:match("image/jpeg") ~= nil)
end

---@param str string
---@return boolean
M.is_image_path = function(str)
  str = string.lower(str)

  local has_path_sep = str:find("/") ~= nil or str:find("\\") ~= nil
  local has_image_ext = str:match("^.*%.(png)$") ~= nil
    or str:match("^.*%.(jpg)$") ~= nil
    or str:match("^.*%.(jpeg)$") ~= nil

  return has_path_sep and has_image_ext
end

return M
