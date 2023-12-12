local img_clip = require("img-clip")
local drag_and_drop = require("img-clip.drag_and_drop")

vim.api.nvim_create_user_command("PasteImage", function()
  img_clip.pasteImage()
end, {})

-- override vim.paste to handle image pasting from system clipboard
-- vim.paste is triggered when the users drops an image or file into the terminal
-- it will contain the path to the image or file, or a link to the image
vim.paste = (function(overridden)
  return function(lines, phase)
    if #lines > 1 or #lines == 0 then
      return overridden(lines, phase)
    end

    if not drag_and_drop.handle_paste(lines[1]) then
      return overridden(lines, phase)
    end
  end
end)(vim.paste)
