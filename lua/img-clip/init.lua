local config = require("img-clip.config")
local paste = require("img-clip.paste")

local M = {}

---@param opts? table
M.setup = function(opts)
  config.setup(opts)
end

---@param opts? table
---@param input? string
M.paste_image = function(opts, input)
  return paste.paste_image(opts, input)
end

---@param opts? table
---@param input? string
M.pasteImage = function(opts, input)
  return paste.paste_image(opts, input)
end

return M
