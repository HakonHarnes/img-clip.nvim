local M = {}

M.executable = function(command)
	return vim.fn.executable(command) == 1
end

M.has = function(feature)
	return vim.fn.has(feature) == 1
end

return M
