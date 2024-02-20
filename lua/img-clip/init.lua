local clipboard = require("img-clip.clipboard")
local config = require("img-clip.config")
local paste = require("img-clip.paste")
local util = require("img-clip.util")

local M = {}

---@param opts? table
M.setup = function(opts)
  config.setup(opts)

  if not clipboard.get_clip_cmd() then
    util.error("Could not get clipboard command. See :checkhealth img-clip.")
  end
end

---@param opts? table
---@param input? string
M.pasteImage = function(opts, input)
  return paste.paste_image(opts, input)
end

return M
