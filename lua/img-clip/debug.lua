local M = {}

M.debug_log = {}

M.log = function(msg)
  table.insert(M.debug_log, msg)
end

M.print_log = function()
  for _, msg in ipairs(M.debug_log) do
    print(msg)
  end
end

return M
