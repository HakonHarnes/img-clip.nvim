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

M.get_filepath = function()
  local path_separator = package.config:sub(1, 1)
  local filepath = config.get_option("filepath")
  local filename = "image.png"

  local full_filepath = vim.fn.resolve(filepath .. path_separator .. filename)

  os.execute("mkdir -p " .. filepath)

  return full_filepath
end

return M
