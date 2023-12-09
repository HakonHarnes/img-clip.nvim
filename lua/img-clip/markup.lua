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

---@param row number
---@param lines string[]
---@return number new_row The new cursor row pos
---@return string matched_line The matched line in the tempalte (or the last line if no match)
---@return number matched_line_index The index of the matched line
function M.get_new_cursor_row(row, lines)
  for i, line in ipairs(lines) do
    if line:match("$CURSOR") then
      return row + i, line, i
    end
  end

  return row + #lines, lines[#lines], #lines
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

---@param file_path string
---@param opts? table
---@return boolean
function M.insert_markup(file_path, opts)
  local template = config.get_option("template", opts)
  if not template then
    return false
  end

  local file_name = vim.fn.fnamemodify(file_path, ":t")

  template = template:gsub("$FILEPATH", file_path)
  template = template:gsub("$FILENAME", file_name)
  local lines = M.split_lines(template)

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local cur_row = cur_pos[1]

  local new_row, line, index = M.get_new_cursor_row(cur_row, lines)
  local new_col = M.get_new_cursor_col(line)

  lines[index] = line:gsub("$CURSOR", "")

  vim.api.nvim_put(lines, "l", true, true)
  vim.api.nvim_win_set_cursor(0, { new_row, new_col })

  if config.get_option("cursor_insert_mode", opts) then
    vim.cmd("startinsert")
  end

  return true
end

return M
