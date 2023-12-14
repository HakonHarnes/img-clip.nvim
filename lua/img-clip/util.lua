local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
end

---@param cmd string
---@param powershell boolean
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
    command = "powershell.exe -Command '" .. cmd:gsub("'", '"') .. "'"

  -- cmd.exe requires the command to have the format:
  -- powershell.exe -Command "command 'path/to/file'"
  else
    command = 'powershell.exe -Command "' .. cmd:gsub('"', "'") .. '"'
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

return M
