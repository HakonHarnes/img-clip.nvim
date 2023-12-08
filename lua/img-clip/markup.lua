local config = require("img-clip.config")

local M = {}

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

function M.get_new_row(row, lines)
  for i, line in ipairs(lines) do
    if line:match("$CURSOR") then
      return row + i, line, i
    end
  end

  return row + #lines, lines[#lines], #lines
end

function M.get_new_col(line)
  local cursor_pos = line:find("$CURSOR")
  if cursor_pos then
    return cursor_pos - 1
  end

  return string.len(line) - 1
end

function M.insert_markup(filepath, opts)
  local template = config.get_option("template", opts)
  if not template then
    return false
  end

  local filename = vim.fn.fnamemodify(filepath, ":t")

  template = template:gsub("$FILEPATH", filepath)
  template = template:gsub("$FILENAME", filename)
  local lines = M.split_lines(template)

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local cur_row = cur_pos[1]

  local new_row, line, index = M.get_new_row(cur_row, lines)
  local new_col = M.get_new_col(line)

  lines[index] = line:gsub("$CURSOR", "")

  vim.api.nvim_put(lines, "l", true, true)
  vim.api.nvim_win_set_cursor(0, { new_row, new_col })

  return true
end

return M
