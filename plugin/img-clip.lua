local config = require("img-clip.config")
local paste = require("img-clip.paste")
local util = require("img-clip.util")
local plugin = require("img-clip")

plugin.setup()

vim.api.nvim_create_user_command("PasteImage", function()
  paste.paste_image()
end, {})

local buffer = ""

---@param lines string[]
---@param phase number
local function convert_streaming_paste(lines, phase)
  if phase == 1 then
    buffer = ""
  end

  for i, line in ipairs(lines) do
    buffer = buffer .. line
    if i < #lines then
      buffer = buffer .. "\n"
    end
  end

  if phase == 3 then -- end of the paste
    local complete_lines = vim.split(buffer, "\n")
    vim.paste(complete_lines, -1) -- use -1 to indicate non-streaming paste
  end
end

-- override vim.paste to handle image pasting from system clipboard
-- vim.paste is triggered when the users drops an image or file into the terminal
-- it will contain the path to the image or file, or a link to the image
vim.paste = (function(original)
  return function(lines, phase)
    if config.get_opt("debug") then
      print("Paste: " .. vim.inspect(lines))
    end

    if config.get_opt("drag_and_drop.enabled") == false then
      return original(lines, phase)
    end

    if config.get_opt("drag_and_drop.insert_mode") == false and vim.fn.mode() == "i" then
      return original(lines, phase)
    end

    if phase ~= -1 then
      return convert_streaming_paste(lines, phase)
    end

    if #lines > 2 or #lines == 0 then
      return original(lines, phase)
    end

    local line = lines[1]

    if config.get_opt("debug") then
      print("Line: " .. line)
    end

    -- probably not a file path or url to an image if the input is this long
    if string.len(line) > 512 then
      return original(lines, phase)
    end

    util.verbose = false
    if not paste.paste_image({}, line) then
      if config.get_opt("debug") then
        print("Did not handle paste, calling original vim.paste")
      end
      util.verbose = true
      return original(lines, phase) -- if we did not handle the paste, call the original vim.paste function
    end
  end
end)(vim.paste)
