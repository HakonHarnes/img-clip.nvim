local M = {}

local defaults = {
	relative_path = "./assets",
	absolute_path = "$HOME/assets",

	markdown = {
		template = "![]($PATH)",
	},
	latex = {
		template = "\\includegraphics{$PATH}",
	},
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
