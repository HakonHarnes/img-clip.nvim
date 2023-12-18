local img_clip = require("img-clip")
local config = require("img-clip.config")
local drag_and_drop = require("img-clip.drag_and_drop")

vim.api.nvim_create_user_command("PasteImage", function()
  img_clip.pasteImage()
end, {})

-- override vim.paste to handle image pasting from system clipboard
-- vim.paste is triggered when the users drops an image or file into the terminal
-- it will contain the path to the image or file, or a link to the image
vim.paste = (function(overridden)
  return function(lines, phase)
    if config.get_option("debug") then
      print("Paste: " .. vim.inspect(lines))
    end

    if #lines > 1 or #lines == 0 then
      return overridden(lines, phase)
    end

    local line = lines[1]

    -- probably not a file path or url to an image if the input is this long
    if string.len(line) > 512 then
      return overridden(lines, phase)
    end

    if config.get_option("debug") then
      print("Line: " .. line)
    end

    if not drag_and_drop.handle_paste(lines[1]) then
      if config.get_option("debug") then
        print("Did not handle paste, calling original vim.paste")
      end
      return overridden(lines, phase) -- if drag and drop did not handle the paste, call the original vim.paste function
    end
  end
end)(vim.paste)
