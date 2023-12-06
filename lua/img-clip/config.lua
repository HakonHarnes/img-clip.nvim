local M = {}

local defaults = {
  dir_path = "assets/",
  filename = "%Y-%m-%d-%H-%M-%S",
  prompt_for_filename = true,
  include_filepath_in_prompt = false,
  absolute_path = false,
  template = "$FILEPATH",

  markdown = {
    template = "![$CURSOR]($FILEPATH)",
  },
  latex = {
    template = [[\includegraphics{$FILEPATH}]],
  },
}

M.options = {}

M.get_option = function(key, opts)
  local ft = vim.bo.filetype
  local val

  if opts and opts[key] ~= nil then
    val = opts[key]

  -- Check for filetype-specific option
  elseif M.options[ft] and M.options[ft][key] ~= nil then
    val = M.options[ft][key]
  elseif M.options[key] ~= nil then
    val = M.options[key]
  else
    vim.notify("No option found for " .. key .. ".", vim.log.levels.WARN, { title = "img-clip" })
    return nil
  end

  -- Check if the option is a function and execute it
  if type(val) == "function" then
    return val() -- Execute the function and return its result
  else
    return val -- Return the option value directly
  end
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
