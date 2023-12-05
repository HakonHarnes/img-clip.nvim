local M = {}

local defaults = {
  filepath = "assets",

  markdown = {
    template = "![]($PATH)",
  },
  latex = {
    template = "\\includegraphics{$PATH}",
  },
}

M.options = {}

M.get_option = function(key)
  return M.options[key]
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
