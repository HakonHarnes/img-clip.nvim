local util = require("img-clip.util")
local config = require("img-clip.config")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local cmd = nil

M.pasteImage = function()
  if not cmd then
    cmd = util.get_cmd()
    if not cmd then
      return
    end
  end

  print(cmd)

  -- todo: rest of function here
end

return M
