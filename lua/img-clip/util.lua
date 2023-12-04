local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
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

M.execute = function(cmd)
  M.debug("Executing: " .. cmd)

  local handle = io.popen(cmd)
  if not handle then
    M.error("Failed to execute command: " .. cmd)
    return nil
  end

  local result = handle:read("*a")
  handle:close()

  return result
end

return M
