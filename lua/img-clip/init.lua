local config = require("img-clip.config")

local M = {}

M.setup = function(opts)
	config.setup(opts)
end

M.pasteImage = function()
	P(config.options)
end

return M
