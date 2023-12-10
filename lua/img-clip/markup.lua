local config = require("img-clip.config")

local M = {}

---@param template string
---@return string[]
function M.split_lines(template)
  local lines = vim.split(template, "\n")

  if lines[1] and lines[1]:match("^%s*$") then
    table.remove(lines, 1)
  end

  if lines[#lines] and lines[#lines]:match("^%s*$") then
    table.remove(lines)
  end

  return lines
end

---@param cur_row number
---@param lines string[]
---@return number new_row The new cursor row pos
---@return string matched_line The matched line in the tempalte (or the last line if no match)
---@return number matched_line_index The index of the matched line
function M.get_new_cursor_row(cur_row, lines)
  for i, line in ipairs(lines) do
    if line:match("$CURSOR") then
      return cur_row + i, line, i
    end
  end

  return cur_row + #lines, lines[#lines], #lines
end

---@param line string
---@return number new_col The new cursor col pos
function M.get_new_cursor_col(line)
  local cursor_pos = line:find("$CURSOR")
  if cursor_pos then
    return cursor_pos - 1
  end

  return string.len(line) - 1
end

---@param str string
---@return string
M.url_encode = function(str)
  if str then
    str = str:gsub("\\", "/")
    str = str:gsub("[ :]", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
  end
  return str
end

---@param file_path string
---@param opts? table
---@return boolean
function M.insert_markup(file_path, opts)
  local template = config.get_option("template", opts)
  if not template then
    return false
  end

  local file_name = vim.fn.fnamemodify(file_path, ":t")
  local file_name_no_ext = vim.fn.fnamemodify(file_path, ":t:r")
  local label = file_name_no_ext:gsub("%s+", "-"):lower()

  -- url encode path
  if config.get_option("url_encode_path", opts) then
    file_path = M.url_encode(file_path)
    file_path = file_path:gsub("%%", "%%%%") -- escape % so we can call gsub again
  end

  print(file_path)

  template = template:gsub("$FILE_NAME_NO_EXT", file_name_no_ext)
  template = template:gsub("$FILE_NAME", file_name)
  template = template:gsub("$FILE_PATH", file_path)
  template = template:gsub("$LABEL", label)

  if not config.get_option("use_cursor_in_template", opts) then
    template = template:gsub("$CURSOR", "")
  end

  local lines = M.split_lines(template)

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local cur_row = cur_pos[1]

  local new_row, line, index = M.get_new_cursor_row(cur_row, lines)
  local new_col = M.get_new_cursor_col(line)

  lines[index] = line:gsub("$CURSOR", "")

  vim.api.nvim_put(lines, "l", true, true)

  vim.api.nvim_win_set_cursor(0, { new_row, new_col })

  if config.get_option("insert_mode_after_paste", opts) then
    if new_col == string.len(line) - 1 then
      vim.api.nvim_input("a")
    else
      vim.api.nvim_input("i")
    end
  end

  return true
end

return M
