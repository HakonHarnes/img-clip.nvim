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
  if not powershell then
    return vim.fn.system(cmd), vim.v.shell_error
  end

  -- Powershell and pwsh can execute .NET commands directly
  local shell = vim.o.shell:lower()
  if shell:match("powershell") or shell:match("pwsh") then
    return vim.fn.system(cmd), vim.v.shell_error

  -- WSL requires the command to have the format:
  -- powershell.exe -Command 'command "path/to/file"'
  elseif M.has("wsl") then
    cmd = cmd:gsub("'", '"')
    return vim.fn.system("powershell.exe -Command '" .. cmd .. "'"), vim.v.shell_error

    -- cmd.exe requires the command to have the format:
    -- powershell.exe -Command "command 'path/to/file'"
  else
    cmd = cmd:gsub('"', "'")
    return vim.fn.system('powershell.exe -Command "' .. cmd .. '"'), vim.v.shell_error
  end
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
