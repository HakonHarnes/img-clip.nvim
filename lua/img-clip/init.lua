local clipboard = require("img-clip.clipboard")
local config = require("img-clip.config")
local util = require("img-clip.util")

local M = {}

---@param opts? table
M.setup = function(opts)
  config.setup(opts)

  if not clipboard.get_clip_cmd() then
    util.error("Could not get clipboard command. See :checkhealth img-clip.")
  end
end

return M
