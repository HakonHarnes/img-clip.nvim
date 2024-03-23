local config = require("img-clip.config")
local paste = require("img-clip.paste")

local M = {}

---@param config_opts? table
M.setup = function(config_opts)
  config.setup(config_opts)
end

---@param api_opts? table
---@param input? string
M.paste_image = function(api_opts, input)
  config.api_opts = api_opts or {}
  return paste.paste_image(input)
end

---@param api_opts? table
---@param input? string
M.pasteImage = function(api_opts, input)
  config.api_opts = api_opts or {}
  return paste.paste_image(input)
end

return M
