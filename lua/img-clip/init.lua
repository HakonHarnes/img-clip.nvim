local util = require("img-clip.util")
local config = require("img-clip.config")

local M = {}

M.setup = function(opts)
	config.setup(opts)
end

local deps_ok = false

M.pasteImage = function()
	-- check dependencies (e.g. xclip, osascript...)
	if not deps_ok then
		deps_ok = util.check_deps()
		if not deps_ok then
			return
		end
	end

	-- todo: rest of function here
end

return M
