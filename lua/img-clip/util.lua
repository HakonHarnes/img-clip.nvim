local config = require("img-clip.config")

local M = {}

M.executable = function(command)
  return vim.fn.executable(command) == 1
end

---@param cmd string
---@return string | nil output
---@return number exit_code
M.execute = function(cmd)
  return vim.fn.system(cmd), vim.v.shell_error
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
-- lua pattern matching doesn't support the | operator, hence the repetition
M.is_image_url = function(str)
  return str:match("^https?://.*%.png") ~= nil
    or str:match("^https?://.*%.jpg") ~= nil
    or str:match("^https?://.*%.jpeg") ~= nil
end

---@param str string
---@return boolean
M.is_image_path = function(str)
  return str:match("^.*%.(png)$") ~= nil or str:match("^.*%.(jpg)$") ~= nil or str:match("^.*%.(jpeg)$") ~= nil
end

return M
