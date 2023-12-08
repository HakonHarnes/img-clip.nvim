local M = {}

local defaults = {
  dir_path = "assets",
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

  -- check options passed explicitly to pasteImage function
  if opts and opts[key] ~= nil then
    val = opts[key]

  -- otherwise chck for filetype-specific option
  elseif M.options[ft] and M.options[ft][key] ~= nil then
    val = M.options[ft][key]

  -- otherwise check for global option
  elseif M.options[key] ~= nil then
    val = M.options[key]

  -- return nil if no option found
  else
    vim.notify("No option found for " .. key .. ".", vim.log.levels.WARN, { title = "img-clip" })
    return nil
  end

  if type(val) == "function" then
    return val() -- execute the function and return its result
  else
    return val
  end
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
